# Builds a Docker image with OpenFOAM, CalculiX and sfepy, based on
# Ubuntu 17.10 for multiphysics coupling 
#
# The built image can be found at:
#   https://hub.docker.com/r/unifem/openfoam-cxx
#
# Authors:
# Xiangmin Jiao <xmjiao@gmail.com>

# Use mapper-desktop as base image
FROM unifem/mapper-desktop:latest
LABEL maintainer "Xiangmin Jiao <xmjiao@gmail.com>"

USER root
WORKDIR /tmp

# Install OpenFOAM 5.0 (https://openfoam.org/download/5-0-ubuntu/), 
# Calculix, along with FreeCAD and Gmsh
RUN add-apt-repository http://dl.openfoam.org/ubuntu && \
    sh -c "curl -s http://dl.openfoam.org/gpg.key | apt-key add -" && \
    add-apt-repository ppa:nschloe/gmsh-backports && \
    add-apt-repository ppa:freecad-maintainers/freecad-stable && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        openfoam5 \
        paraviewopenfoam54 \
        freecad \
        calculix-ccx \
        gmsh \
        libsuitesparse-dev && \
    apt-get clean && \
    pip3 install -U \
        cython \
        pyparsing \
        scikit-umfpack \
        tables \
        pymetis \
        pyamg \
        pyface && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# Install sfepy (without pysparse and mayavi)
ARG SFEPY_VERSION=2017.3

RUN pip3 install --no-cache-dir \
        https://bitbucket.org/dalcinl/igakit/get/default.tar.gz && \
    pip3 install --no-cache-dir \
        https://github.com/sfepy/sfepy/archive/release_${SFEPY_VERSION}.tar.gz

ADD image/home $DOCKER_HOME

USER $DOCKER_USER
WORKDIR $DOCKER_HOME

# Source configuration for bash
# https://github.com/OpenFOAM/OpenFOAM-dev/tree/version-5.0/etc
RUN echo "source /opt/openfoam5/etc/bashrc" >> $DOCKER_HOME/.profile

USER root
