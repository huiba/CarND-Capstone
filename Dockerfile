# Udacity capstone project dockerfile
FROM ros:kinetic-robot
LABEL maintainer="olala7846@gmail.com"

ARG USERNAME=docker_user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install Dataspeed DBW https://goo.gl/KFSYi1 from binary
# adding Dataspeed server to apt
RUN sh -c 'echo "deb [ arch=amd64 ] http://packages.dataspeedinc.com/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-dataspeed-public.list'
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FF6D3CDA
RUN apt-get update

# setup rosdep
RUN sh -c 'echo "yaml http://packages.dataspeedinc.com/ros/ros-public-'$ROS_DISTRO'.yaml '$ROS_DISTRO'" > /etc/ros/rosdep/sources.list.d/30-dataspeed-public-'$ROS_DISTRO'.list'
RUN rosdep update
RUN apt-get install -y ros-$ROS_DISTRO-dbw-mkz
RUN apt-get upgrade -y
# end installing Dataspeed DBW

# install python packages
RUN apt-get install -y python-pip
RUN pip install --upgrade "pip < 21.0"
COPY requirements.txt ./requirements.txt
RUN pip install -r requirements.txt

# install required ros dependencies
RUN apt-get install -y ros-$ROS_DISTRO-cv-bridge
RUN apt-get install -y ros-$ROS_DISTRO-pcl-ros
RUN apt-get install -y ros-$ROS_DISTRO-image-proc

# socket io
RUN apt-get install -y netbase

RUN mkdir /capstone
VOLUME ["/capstone"]
VOLUME ["/root/.ros/log/"]
WORKDIR /capstone/ros

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo wget vim \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*


USER $USERNAME
# Default powerline10k theme, no plugins installed
RUN sh -c "$(wget -O- https://github.com/huiba/zsh-in-docker/releases/download/v1.1.2/zsh-in-docker.sh)"


ENTRYPOINT [ "/bin/zsh" ]
CMD ["-l"]

