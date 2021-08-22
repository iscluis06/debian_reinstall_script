#!/bin/bash
#Instalación basada en qtile y xorg
PACKAGES_TO_INSTALL=" xorg xserver-xorg libcairo2 python3-pip libgdk-pixbuf2.0-0 libpangocairo-1.0-0 vim htop screenfetch fonts-ubuntu fonts-powerline git openjdk-11-jdk flatpak nodejs npm chromium firefox-esr ffmpeg obs-studio kitty vlc gimp gmtp pulseaudio pavucontrol unrar zip"

echo "¿Instalar iwlwifi (Controladores para tarjetas wifi intel/tp-link)? Si/No"
read iwlwifi

echo "¿Instalar driver de nvidia? Si/No"
read nvidia

echo "¿Instalar paquetes de virtualizacion? Si/No"
read qemu

echo "Especificar usuario a configurar: "
read user

echo "¿Instalar oh my bash? Si/No"
read ohmybash

echo "¿Instalar discord(flatpak)? Si/No"
read discord

echo "¿Instalar kdenlive(flatpak)? Si/No"
read kdenlive

echo "¿Instalar dropbox(flatpak)? Si/No"
read dropbox

if [ "${iwlwifi,,}" = "si" ]
then
    PACKAGES_TO_INSTALL="${PACKAGES_TO_INSTALL} iwlwifi"
fi

if [ "${nvidia,,}" = "si" ]
then
    PACKAGES_TO_INSTALL="${PACKAGES_TO_INSTALL} nvidia-driver"
fi

if [ "${qemu,,}" = "si" ]
then
    PACKAGES_TO_INSTALL="${PACKAGES_TO_INSTALL} qemu qemu-system libvirt-clients libvirt-daemon-system"
fi

sed -i 's/deb http:\/\/deb.debian.org\/debian\/ bullseye main/deb http:\/\/deb.debian.org\/debian\/ bullseye main non-free contrib/' /etc/apt/sources.list
sed -i 's/deb-src http:\/\/deb.debian.org\/debian\/ bullseye main/deb-src http:\/\/deb.debian.org\/debian\/ bullseye main non-free contrib/' /etc/apt/sources.list

apt update
apt install $PACKAGES_TO_INSTALL -y
pip3 install xcffib && pip3 install cairocffi && pip3 install qtile

runuser -l $user -c "cd ~"
if [ ! -f "/home/${user}/.xinitrc" ]
    then
        runuser -l $user -c 'touch .xinitrc'
fi

grep -q '/usr/local/bin/qtile start' .xinitrc

if [ $0 -ne 0 ]
    then
        runuser -l $user -c 'echo "/usr/local/bin/qtile start" >> .xinitrc'
fi

if [ "${ohmybash,,}" = "si" ]
then
    if [ ! -d "/home/${user}/.oh-my-bash" ]
    	then
    		runuser -l $user -c 'sh -c "$(wget https://raw.github.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"'
    		exit
    		runuser -l $user -c 'sed -i "s/OSH_THEME=\"font\"/OSH_THEME=\"powerline\"/" .bashrc'
    	fi
fi

grep -q 'case $(tty) in /dev/tty1)'

if [ $0 -ne 0 ]
    then
        runuser -l $user -c 'echo "case $(tty) in /dev/tty1)" >> .bashrc'
	runuser -l $user -c 'echo "    startx ;;" >> .bashrc'
	runuser -l $user -c 'echo "esac" >> .bashrc'
fi

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

if [ "${discord,,}" = "si" ]
then
    flatpak install flathub com.discordapp.Discord -y
fi

if [ "${kdenlive,,}" = "si" ]
then
    flatpak install flathub org.kde.kdenlive -y
fi

if [ "${dropbox,,}" = "si" ]
then
    flatpak install flathub com.dropbox.Client -y
fi

echo "Proceso de instalación finalizado"
exit
