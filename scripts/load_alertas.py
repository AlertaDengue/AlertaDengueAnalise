"""Validate generated alert SQL and apply both diseases in one transaction."""

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path


TARGETS = {
    "output_dengue.sql": ("Historico_alerta", "alertas_unicos"),
    "output_chik.sql": ("Historico_alerta_chik", "alertas_unicos_chik"),
}
INSERT = re.compile(
    r'^INSERT INTO "Municipio"\."(?P<table>Historico_alerta(?:_chik)?)" '
    r'\((?P<columns>[^\n]+)\) VALUES \((?P<week>\d{6}),'
    r"(?P<values>[^\n]+)\)\s*$"
)
CONFLICT = re.compile(r"^\s*ON CONFLICT ON CONSTRAINT (\w+)\s*$")
UPDATE = re.compile(r"^\s*DO UPDATE SET (.+);\s*$")
IDENTIFIER = r'(?:"[A-Za-z_][A-Za-z_0-9]*"|[A-Za-z_][A-Za-z_0-9]*)'
ASSIGNMENT = re.compile(rf"^({IDENTIFIER})=excluded\.({IDENTIFIER})$")
ROW_KEY = re.compile(r"^'[^']+',(?:[^,]+,){5}(\d{7})(?:,|$)")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def validate_week(week: str) -> None:
    require(bool(re.fullmatch(r"\d{4}(0[1-9]|[1-4]\d|5[0-3])", week)),
            "--week must be a valid YYYYWW value")


def validate_file(path: Path, week: str, table: str, constraint: str) -> None:
    found_week = False
    with path.open(encoding="utf-8") as source:
        lines = (line.rstrip("\n") for line in source if line.strip())
        offset = 0
        while (insert_line := next(lines, None)) is not None:
            conflict_line = next(lines, None)
            update_line = next(lines, None)
            require(conflict_line is not None and update_line is not None,
                    f"invalid SQL structure: {path}")
            first = INSERT.fullmatch(insert_line)
            second = CONFLICT.fullmatch(conflict_line)
            third = UPDATE.fullmatch(update_line)
            require(first is not None and second is not None and third is not None,
                    f"unexpected SQL statement in {path} at line {offset + 1}")
            require(first["table"] == table and second[1] == constraint,
                    f"unexpected SQL target in {path} at line {offset + 1}")
            require(";" not in insert_line and "--" not in insert_line and
                    "/*" not in insert_line and "\\" not in insert_line,
                    f"unexpected SQL content in {path} at line {offset + 1}")
            columns = first["columns"].split(",")
            require(columns[:2] == ['"SE"', '"data_iniSE"'] and
                    "municipio_geocodigo" in columns,
                    f"unexpected SQL columns in {path} at line {offset + 1}")
            assignments = third[1].split(",")
            require(len(assignments) == len(columns),
                    f"unexpected SQL update in {path} at line {offset + 3}")
            for column, assignment in zip(columns, assignments):
                match = ASSIGNMENT.fullmatch(assignment)
                require(match is not None and match[1] == column and match[2] == column,
                        f"unexpected SQL update in {path} at line {offset + 3}")
            row_week = first["week"]
            require("201001" <= row_week <= week,
                    f"SQL week outside requested range in {path}: {row_week}")
            key = ROW_KEY.match(first["values"])
            require(key is not None, f"invalid municipality key in {path}")
            found_week |= row_week == week
            offset += 3
    require(found_week,
            f"SQL does not contain requested week {week}: {path}")


def db_value(modern: str, legacy: str, default: str = "") -> str:
    return os.environ.get(modern, os.environ.get(legacy, default))


def run(week: str, sql_dir: Path) -> int:
    validate_week(week)
    host = db_value("ALERTA_DB_HOST", "DB_HOST")
    port = db_value("ALERTA_DB_PORT", "DB_PORT", "5432")
    name = db_value("ALERTA_DB_NAME", "DB_NAME")
    user = db_value("ALERTA_DB_USER", "DB_USER")
    password = db_value("ALERTA_DB_PASSWORD", "DB_PASSWORD")
    require(all((host, name, user, password)) and
            bool(re.fullmatch(r"[0-9]{1,5}", port)) and 1 <= int(port) <= 65535,
            "missing or invalid database configuration (ALERTA_DB_* or DB_*)")
    files = [sql_dir / filename for filename in TARGETS]
    for path in files:
        require(path.is_file() and path.stat().st_size > 0,
                f"required current-run SQL missing or empty: {path}")
    for path, (table, constraint) in zip(files, TARGETS.values()):
        validate_file(path, week, table, constraint)
    print(f"[II] validated dengue and chik SQL for week={week}", flush=True)
    env = os.environ.copy()
    env["PGPASSWORD"] = password
    command = ["psql", "-X", "-v", "ON_ERROR_STOP=1", "--single-transaction",
               "-h", host, "-p", port, "-U", user, "-d", name]
    for path in files:
        command.extend(("-f", str(path)))
    try:
        result = subprocess.run(command, env=env, check=False)
    except OSError as exc:
        print(f"ERROR: cannot start psql: {exc}", file=sys.stderr)
        return 1
    if result.returncode:
        print(
            f"ERROR: SQL load failed (psql exit {result.returncode})",
            file=sys.stderr,
        )
    return result.returncode


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--week", required=True)
    parser.add_argument("--sql-dir", required=True, type=Path)
    args = parser.parse_args()
    try:
        return run(args.week, args.sql_dir)
    except (ValueError, OSError, UnicodeError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
