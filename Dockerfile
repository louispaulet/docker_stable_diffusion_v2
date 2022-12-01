#get latest pytorch env (nightly for functorch)
FROM ghcr.io/pytorch/pytorch-nightly:latest

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

RUN set -eux; \
    apt-get update -y && apt-get install -y \
       python3 python3-pip \
    ; \
    rm -rf /var/lib/apt/lists/*

# needed for triton and xformers
RUN apt-get update -y && apt-get -y install git

# install diffusers and helpers
RUN /bin/bash -c "pip install --upgrade diffusers[torch]"
RUN pip install --upgrade diffusers transformers scipy numpy==1.23.4 protobuf
RUN pip install accelerate ftfy

# build triton for xformers
RUN git clone https://github.com/openai/triton.git;
WORKDIR triton/python
RUN pip install cmake; # build time dependency
RUN pip install -e .

# ninja and xformers needed for transformer acceleration
# (Optional) Makes the build much faster
RUN pip install ninja
# Set TORCH_CUDA_ARCH_LIST if running and building on different GPU types
RUN export TORCH_CUDA_ARCH_LIST="6.0;6.1;6.2;7.0;7.2;7.5;8.0;8.6"
RUN pip install -v -U git+https://github.com/facebookresearch/xformers.git@main#egg=xformers
# (this can take dozens of minutes)

# install base libs
RUN pip install \
    scikit-learn \
    pandas \
    seaborn \
    jupyterlab \
    jupyterlab_widgets \
    ipywidgets \
    jupyter-dash

# create project dir
RUN mkdir ../project
WORKDIR /project