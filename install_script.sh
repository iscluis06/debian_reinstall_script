#!/bin/bash
#Instalación basada en qtile y xorg
PACKAGES_TO_INSTALL=" xorg xserver-xorg libcairo2 python3-pip libgdk-pixbuf2.0-0 libpangocairo-1.0-0 vim htop screenfetch fonts-ubuntu fonts-powerline git openjdk-11-jdk flatpak nodejs npm chromium firefox-esr ffmpeg obs-studio kitty vlc gimp gmtp pulseaudio pavucontrol unrar zip fonts-font-awesome fonts-noto-mono"

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

echo "¿Configurar qtile? Si/No"
read qtile_config

if [ "${iwlwifi,,}" = "si" ]
then
    PACKAGES_TO_INSTALL="${PACKAGES_TO_INSTALL} firmware-iwlwifi"
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

if [ $? -ne 0 ]
    then
        runuser -l $user -c 'echo "/usr/local/bin/qtile start" >> .xinitrc'
fi

if [ "${ohmybash,,}" = "si" ]
then
    if [ ! -d "/home/${user}/.oh-my-bash" ]
    	then
    		runuser -l $user -c 'wget https://raw.github.com/ohmybash/oh-my-bash/master/tools/install.sh -O ohmybash.sh'
		runuser -l $user -c "sed -i 's/exec bash; source \$HOME\/.bashrc/exit/' ohmybash.sh"
		chmod +x /home/$user/ohmybash.sh
    		runuser -l $user -c './ohmybash.sh'
    		runuser -l $user -c 'sed -i "s/OSH_THEME=\"font\"/OSH_THEME=\"powerline\"/" .bashrc'
		echo "termina proceso instalacion oh-my-bash"
    	fi
	echo "saliendo de oh-my-bash if"
fi

echo "comenzando prueba de terminal virtual tty1"
grep -q 'case \$(tty) in /dev/tty1)' /home/$user/.bashrc

if [ $? -ne 0 ]
    then
        runuser -l $user -c 'echo "case \$(tty) in /dev/tty1)" >> .bashrc'
	runuser -l $user -c 'echo "if [ \$(pgrep Xorg -c) -eq 0 ]" >> .bashrc'
	runuser -l $user -c 'echo "then" >> .bashrc'
	runuser -l $user -c 'echo "    		startx" >> .bashrc'
	runuser -l $user -c 'echo "	fi" >> .bashrc'
	runuser -l $user -c 'echo "esac" >> .bashrc'
	echo "Configurada sesion de qtile en xorg"
fi

echo "configurando flathub en flatpak"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

if [ "${discord,,}" = "si" ]
then
    echo "Instalando discord..."
    flatpak install flathub com.discordapp.Discord -y
fi

if [ "${kdenlive,,}" = "si" ]
then
    echo "Instalando kdenlive"
    flatpak install flathub org.kde.kdenlive -y
fi

if [ "${dropbox,,}" = "si" ]
then
    echo "Instalando dropbox..."
    flatpak install flathub com.dropbox.Client -y
fi

if [ "${qtile_config,,}" = "si" ]
then
   echo "Configurando qtile..."
   runuser -l $user -c 'mkdir tmp && cd tmp'
   runuser -l $user -c 'git clone https://github.com/iscluis06/qtile_config.git tmp/qtile_config'
   runuser -l $user -c 'mkdir ~/Images'
   runuser -l $user -c 'mkdir -p ~/.config/qtile'
   runuser -l $user -c '\cp -r tmp/qtile_config/config.py ~/.config/qtile'
   runuser -l $user -c '\cp -r tmp/qtile_config/wolf01.jpg ~/Images/'
   runuser -l $user -c 'cd ~ && rm -R -f tmp'
fi

echo "Proceso de instalación finalizado"
exit
