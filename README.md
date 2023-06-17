# yocto

VERSION=18.04
docker pull ubuntu:${VERSION}

docker rm -f ubuntu-${VERSION}
docker rm -f ubuntu-${VERSION}-bitbake
docker rmi -f ubuntu:${VERSION}-bitbake
docker run --rm -itd --name ubuntu-${VERSION} ubuntu:${VERSION}
#docker exec -it ubuntu-${VERSION} /bin/bash
docker exec -i ubuntu-${VERSION} /bin/bash <<EOF
apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
export LANG=en_US.UTF-8
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true
echo "tzdata tzdata/Areas select Europe" | debconf-set-selections
echo "tzdata tzdata/Zones/Europe select Madrid" | debconf-set-selections
apt update && apt-get install -y tzdata
EOF

GID=$(id -g)
docker exec -i ubuntu-${VERSION} /bin/bash <<EOF
export LANG=en_US.UTF-8
apt update
apt-get install -y gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint3 xterm python3-subunit mesa-common-dev
groupadd -g ${GID} yocto
useradd -m -u ${UID} -g ${GID} yocto
EOF

IMAGEID=$(docker ps | grep ubuntu-${VERSION} | cut -d' ' -f1)
docker commit ${IMAGEID} ubuntu:${VERSION}-bitbake
docker rm -f ubuntu-${VERSION}

mkdir -p ~/Documents/TASE/git/obsw/yocto-3.3.2
docker run --rm -itd --name ubuntu-${VERSION}-bitbake -v ~/Documents/TASE/git/obsw/yocto-3.3.2:/home/yocto ubuntu:${VERSION}-bitbake
#docker rm -f ubuntu-${VERSION}-bitbake
#docker exec -it -u yocto ubuntu-${VERSION}-bitbake /bin/bash
docker exec -i -u yocto ubuntu-${VERSION}-bitbake /bin/bash <<EOF
export LANG=en_US.UTF-8
git clone git://git.yoctoproject.org/poky ~/poky
cd ~/poky
git checkout -b hardknott-3.3.2-tase tags/hardknott-3.3.2
EOF

source oe-init-build-env
bitbake core-image-sato


docker run --rm -itd --name ubuntu-${VERSION}-bitbake -v ~/yocto:/home/yocto/yocto ubuntu:${VERSION}-bitbake
docker exec -it -u yocto ubuntu-${VERSION}-bitbake /bin/bash
source ~/yocto/imagin-e-setup-env
bitbake fsl-image-networking-full

docker rm -f ubuntu-${VERSION}-bitbake
docker rmi -f ubuntu:${VERSION}-bitbake

IMAGEID=`docker commit ubuntu-${VERSION}-bitbake`
IMAGEID=${IMAGEID/sha256:/}
docker tag ${IMAGEID} ubuntu:${VERSION}-bitbake
docker rm -f ubuntu-${VERSION}-bitbake