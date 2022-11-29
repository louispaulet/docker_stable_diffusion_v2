#get latest pytorch env
FROM pytorch/pytorch

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

RUN set -eux; \
    apt-get update -y && apt-get install -y \
       python3 python3-pip \
    ; \
    rm -rf /var/lib/apt/lists/*

# needed for xformers
RUN apt-get update -y && apt-get -y install git

# install diffusers and helpers
RUN /bin/bash -c "pip install --upgrade diffusers[torch]"
RUN pip install --upgrade diffusers transformers scipy numpy==1.23.4 protobuf
RUN pip install accelerate ftfy


# ninja and xformers needed for transformer acceleration
# (Optional) Makes the build much faster
RUN pip install ninja
# Set TORCH_CUDA_ARCH_LIST if running and building on different GPU types
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