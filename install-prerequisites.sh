#!/bin/env bash
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Script must be run as root"
    exit
fi

CODENAME=$(lsb_release -c -s)

dpkg --add-architecture i386
mkdir -pm755 /etc/apt/keyrings
wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/${CODENAME}/winehq-${CODENAME}.sources
apt update
ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime
export DEBIAN_FRONTEND=noninteractive
apt-get install -y --no-install-recommends tzdata
dpkg-reconfigure --frontend noninteractive tzdata
apt install -y screen sudo wget
echo steam steam/question select "I AGREE" | sudo debconf-set-selections
echo steam steam/license note '' | sudo debconf-set-selections
apt install -y --install-recommends winehq-stable steamcmd lib32gcc-s1 xvfb
apt dist-upgrade -y
apt upgrade -y
apt autoremove -y
useradd -m steam