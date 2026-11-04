"""Offline integration tests for the Makim SQL loading stage."""

import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class LoadAlertasTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "scripts").mkdir()
        (self.root / "sql").mkdir()
        (self.root / "bin").mkdir()
        shutil.copy(ROOT / ".makim.yaml", self.root)
        for name in ("load_env.sh", "load_alertas.py"):
            shutil.copy(ROOT / "scripts" / name, self.root / "scripts")
        self.psql_log = self.root / "psql-args"
        self.psql = self.root / "bin" / "psql"
        self.psql.write_text(
            "#!/bin/sh\nprintf '%s\\n' \"$@\" > \"$PSQL_ARGS_LOG\"\n"
            "exit \"${PSQL_EXIT:-0}\"\n"
        )
        self.psql.chmod(0o755)
        self.env = os.environ.copy()
        for key in list(self.env):
            if key.startswith(("ALERTA_", "DB_", "PG")):
                self.env.pop(key)
        self.env.update({
            "PATH": str(self.root / "bin") + os.pathsep + os.environ["PATH"],
            "ALERTA_OUT_DIR": str(self.root),
            "ALERTA_DB_HOST": "runtime-host",
            "ALERTA_DB_NAME": "test-db",
            "ALERTA_DB_USER": "test-user",
            "ALERTA_DB_PASSWORD": "test-password",
            "PSQL_ARGS_LOG": str(self.psql_log),
        })

    def sql(self, table: str, constraint: str, week: str = "202520",
            municipality: str = "5300108") -> str:
        return (
            f'INSERT INTO "Municipio"."{table}" '
            '("SE","data_iniSE",casos_est,casos_est_min,casos_est_max,'
            'casos,casprov,municipio_geocodigo) '
            f"VALUES ({week},'2025-05-11',1,1,1,1,1,{municipality}) \n"
            f" ON CONFLICT ON CONSTRAINT {constraint}  \n"
            ' DO UPDATE SET "SE"=excluded."SE",'
            '"data_iniSE"=excluded."data_iniSE",'
            'casos_est=excluded.casos_est,'
            'casos_est_min=excluded.casos_est_min,'
            'casos_est_max=excluded.casos_est_max,'
            'casos=excluded.casos,casprov=excluded.casprov,'
            'municipio_geocodigo=excluded.municipio_geocodigo;\n'
        )

    def write_sql(self) -> None:
        (self.root / "sql" / "output_dengue.sql").write_text(
            self.sql("Historico_alerta", "alertas_unicos")
        )
        (self.root / "sql" / "output_chik.sql").write_text(
            self.sql("Historico_alerta_chik", "alertas_unicos_chik")
        )

    def run_load(self, week: str = "202520") -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["makim", "pipeline.load-alertas", "--week", week],
            cwd=self.root, env=self.env, text=True, capture_output=True,
            check=False,
        )

    def test_missing_empty_invalid_week_and_wrong_target_fail_before_psql(self) -> None:
        for variant in ("missing", "empty", "wrong-week", "wrong-target", "extra-sql"):
            with self.subTest(variant=variant):
                self.write_sql()
                chik = self.root / "sql" / "output_chik.sql"
                if variant == "missing":
                    chik.unlink()
                elif variant == "empty":
                    chik.write_text("")
                elif variant == "wrong-week":
                    chik.write_text(self.sql(
                        "Historico_alerta_chik", "alertas_unicos_chik", "202519"
                    ))
                elif variant == "wrong-target":
                    chik.write_text(self.sql("Historico_alerta", "alertas_unicos"))
                elif variant == "extra-sql":
                    chik.write_text(chik.read_text() + "DELETE FROM foo;\n")
                self.psql_log.unlink(missing_ok=True)
                result = self.run_load()
                self.assertEqual(result.returncode, 2, result.stdout + result.stderr)
                self.assertFalse(self.psql_log.exists())
        self.write_sql()
        self.assertEqual(self.run_load("202599").returncode, 2)
        self.assertFalse(self.psql_log.exists())

    def test_missing_database_configuration_fails_before_psql(self) -> None:
        self.write_sql()
        self.env.pop("ALERTA_DB_PASSWORD")
        result = self.run_load()
        self.assertEqual(result.returncode, 2, result.stdout + result.stderr)
        self.assertFalse(self.psql_log.exists())

    def test_env_defaults_and_explicit_empty_override(self) -> None:
        self.write_sql()
        (self.root / ".env").write_text(
            "ALERTA_DB_HOST=deployment-host\n"
            "ALERTA_DB_PASSWORD=deployment-password\n"
        )
        self.env.pop("ALERTA_DB_HOST")
        self.assertEqual(self.run_load().returncode, 0)
        args = self.psql_log.read_text().splitlines()
        self.assertEqual(args[args.index("-h") + 1], "deployment-host")
        self.psql_log.unlink()
        self.env["ALERTA_DB_PASSWORD"] = ""
        self.assertEqual(self.run_load().returncode, 2)
        self.assertFalse(self.psql_log.exists())

    def test_disease_coverage_can_differ(self) -> None:
        dengue = self.root / "sql" / "output_dengue.sql"
        chik = self.root / "sql" / "output_chik.sql"
        dengue.write_text(
            self.sql("Historico_alerta", "alertas_unicos", municipality="5300108")
            + self.sql("Historico_alerta", "alertas_unicos", "202519",
                       municipality="5300109")
        )
        chik.write_text(
            self.sql("Historico_alerta_chik", "alertas_unicos_chik",
                     municipality="5300110")
        )
        self.assertEqual(self.run_load().returncode, 0)
        self.assertEqual(self.psql_log.read_text().splitlines().count("-f"), 2)

    def test_failure_then_retry_preserves_override(self) -> None:
        self.write_sql()
        (self.root / ".env").write_text("ALERTA_DB_HOST=deployment-host\n")
        self.env["PSQL_EXIT"] = "3"
        first = self.run_load()
        self.assertEqual(first.returncode, 3, first.stdout + first.stderr)
        args = self.psql_log.read_text().splitlines()
        self.assertIn("--single-transaction", args)
        self.assertIn("ON_ERROR_STOP=1", args)
        self.assertEqual(args[args.index("-h") + 1], "runtime-host")
        self.assertEqual(args.count("-f"), 2)
        self.env.pop("PSQL_EXIT")
        second = self.run_load()
        self.assertEqual(second.returncode, 0, second.stdout + second.stderr)
        self.assertEqual(args, self.psql_log.read_text().splitlines())

    def test_refresh_load_reuses_stage_with_nested_env_override(self) -> None:
        self.write_sql()
        for filename in ("output_dengue.sql", "output_chik.sql"):
            shutil.copy(self.root / "sql" / filename, self.root / filename)
        fake_conda = self.root / "bin" / "fake-conda"
        fake_conda.write_text(
            "#!/bin/sh\n"
            'cp output_dengue.sql "$ALERTA_OUT_DIR/sql/output_dengue.sql"\n'
            'cp output_chik.sql "$ALERTA_OUT_DIR/sql/output_chik.sql"\n'
        )
        fake_conda.chmod(0o755)
        self.env["CONDA_EXE"] = str(fake_conda)
        (self.root / ".env").write_text("ALERTA_DB_HOST=deployment-host\n")
        result = subprocess.run(
            ["makim", "pipeline.refresh-alertas", "--week", "202520", "--load"],
            cwd=self.root, env=self.env, text=True, capture_output=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        args = self.psql_log.read_text().splitlines()
        self.assertEqual(args[args.index("-h") + 1], "runtime-host")

    def test_both_map_tasks_keep_host_override(self) -> None:
        fake_conda = self.root / "bin" / "fake-conda"
        fake_conda.write_text(
            "#!/bin/sh\n"
            'case "$*" in *"python -c"*) echo "$MAP_PREFIX" ;; '
            '*) echo "$ALERTA_DB_HOST" >> "$MAP_HOST_LOG" ;; esac\n'
        )
        fake_conda.chmod(0o755)
        self.env["CONDA_EXE"] = str(fake_conda)
        self.env["MAP_PREFIX"] = str(self.root)
        host_log = self.root / "map-hosts"
        self.env["MAP_HOST_LOG"] = str(host_log)
        (self.root / ".env").write_text("ALERTA_DB_HOST=deployment-host\n")
        for task in ("pipeline.maps-br", "pipeline.maps-state"):
            result = subprocess.run(
                ["makim", task, "--week", "202520"], cwd=self.root,
                env=self.env, text=True, capture_output=True, check=False,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(host_log.read_text().splitlines(),
                         ["runtime-host", "runtime-host"])


if __name__ == "__main__":
    unittest.main()
