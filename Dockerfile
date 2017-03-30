# Builds a Docker image for OpenFOAM and Calculix in a Desktop 
# environment with Ubuntu and LXDE.
#
# The built image can be found at:
#   https://hub.docker.com/r/multiphysics/openfoam-cxx
#
# Authors:
# Xiangmin Jiao <xmjiao@gmail.com>

FROM x11vnc/ubuntu:latest
LABEL maintainer "Xiangmin Jiao <xmjiao@gmail.com>"

USER root
WORKDIR /tmp

# Install OpenFOAM, Calculix, along with FreeCAD and Gmsh
RUN add-apt-repository http://dl.openfoam.org/ubuntu && \
    sh -c "curl -s http://dl.openfoam.org/gpg.key | apt-key add -" && \
    add-apt-repository ppa:freecad-maintainers/freecad-stable && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        openfoam4 \
	freecad \
        calculix-ccx \
        gmsh && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

########################################################
# Customization for user and location
########################################################

ENV MP_USER=multiphysics

# Set up user so that we do not run as root
RUN mv /home/$DOCKER_USER /home/$MP_USER && \
    useradd -m -s /bin/bash -G sudo,docker_env $MP_USER && \
    echo "$MP_USER:docker" | chpasswd && \
    echo "$MP_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    sed -i "s/$DOCKER_USER/$MP_USER/" /home/$MP_USER/.config/pcmanfm/LXDE/desktop-items-0.conf && \
    echo "source /opt/openfoam4/etc/bashrc" >> /home/$MP_USER/.bashrc && \
    chown -R $MP_USER:$MP_USER /home/$MP_USER

ENV DOCKER_USER=$MP_USER \
    DOCKER_GROUP=$MP_USER \
    DOCKER_HOME=/home/$MP_USER \
    HOME=/home/$MP_USER

WORKDIR $DOCKER_HOME

USER root
ENTRYPOINT ["/sbin/my_init","--quiet","--","/sbin/setuser","multiphysics","/bin/bash","-l","-c"]
CMD ["/bin/bash","-l","-i"]
