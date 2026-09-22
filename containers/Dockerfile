FROM condaforge/miniforge3:24.11.3-0

WORKDIR /opt/alertadengueanalise

COPY conda/base.yaml conda/base.yaml
RUN mamba env create --file conda/base.yaml && conda clean --all --yes

ENV CONDA_DEFAULT_ENV=alertadengueanalise \
    CONDA_EXE=/opt/conda/bin/conda \
    PATH=/opt/conda/envs/alertadengueanalise/bin:/opt/conda/bin:${PATH} \
    LD_LIBRARY_PATH=/opt/conda/envs/alertadengueanalise/lib \
    OMP_NUM_THREADS=1 \
    OPENBLAS_NUM_THREADS=1 \
    MKL_NUM_THREADS=1 \
    BLIS_NUM_THREADS=1 \
    VECLIB_MAXIMUM_THREADS=1 \
    RCPP_PARALLEL_NUM_THREADS=1

COPY . .
RUN mamba run --no-capture-output -n alertadengueanalise Rscript --vanilla scripts/install_deps.R \
 && bash scripts/install_inla.sh alertadengueanalise \
 && mamba run --no-capture-output -n alertadengueanalise Rscript --vanilla scripts/check_deps.R \
 && conda clean --all --yes

CMD ["makim", "--help"]
