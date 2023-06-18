FROM ubuntu:18.04

ARG USER_ID
ARG GROUP_ID

RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8
ENV PATH="${PATH}:/home/yocto/poky/scripts:/home/yocto/poky/bitbake/bin"

RUN export DEBIAN_FRONTEND=noninteractive
RUN export DEBCONF_NONINTERACTIVE_SEEN=true
RUN echo "tzdata tzdata/Areas select Europe" | debconf-set-selections
RUN echo "tzdata tzdata/Zones/Europe select Madrid" | debconf-set-selections
RUN apt update && apt-get install -y tzdata

RUN apt-get install -y gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint3 xterm python3-subunit mesa-common-dev

RUN groupadd -g $GROUP_ID yocto
RUN useradd -ms /bin/bash -g $GROUP_ID -u $USER_ID yocto
USER yocto
WORKDIR /home/yocto

CMD ["/bin/bash"]