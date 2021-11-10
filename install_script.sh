#!/bin/bash
#Instalación basada en qtile y xorg
PACKAGES_TO_INSTALL=" xorg xserver-xorg libcairo2 python3-pip libgdk-pixbuf2.0-0 libpangocairo-1.0-0 vim htop screenfetch fonts-ubuntu fonts-powerline git openjdk-11-jdk flatpak nodejs npm chromium firefox-esr ffmpeg obs-studio tilix vlc gimp gmtp pulseaudio pavucontrol unrar zip fonts-font-awesome fonts-noto-mono desktop-base printer-driver-all flameshot vim-gtk compton rofi xfce4-notifyd samba transmission-gtk"

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

echo "¿Instalar bluetooth? Si/No"
read bluetooth

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "¿Multimonitor? Si/No"
read multimonitor

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
    PACKAGES_TO_INSTALL="${PACKAGES_TO_INSTALL} qemu qemu-system libvirt-clients libvirt-daemon-system spice-client-gtk"
fi

if [ "${bluetooth,,}" = "si" ]
then
    PACKAGES_TO_INSTALL="${PACKAGES_TO_INSTALL} bluetooth pulseaudio-module-bluetooth"
fi

sed -i 's/deb http:\/\/deb.debian.org\/debian\/ bullseye main/deb http:\/\/deb.debian.org\/debian\/ bullseye main non-free contrib/' /etc/apt/sources.list
sed -i 's/deb-src http:\/\/deb.debian.org\/debian\/ bullseye main/deb-src http:\/\/deb.debian.org\/debian\/ bullseye main non-free contrib/' /etc/apt/sources.list

apt update
apt install $PACKAGES_TO_INSTALL -y
pip3 install xcffib && pip3 install cairocffi && pip3 install qtile
pip3 install psutil
pip3 install dbus-next

runuser -l $user -c "cd ~"
if [ ! -f "/home/${user}/.xsession" ]
    then
        runuser -l $user -c 'touch .xsession'
fi

grep -q 'exec /usr/local/bin/qtile start' .xsession

if [ $? -ne 0 ]
    then
        runuser -l $user -c 'echo "exec /usr/local/bin/qtile start" >> .xsession'
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
   runuser -l $user -c 'git clone https://github.com/iscluis06/qtile_config.git /tmp/qtile_config'
   runuser -l $user -c 'mkdir ~/Images'
   runuser -l $user -c 'mkdir -p ~/.config/qtile'
   runuser -l $user -c '\cp -r tmp/qtile_config/config.py ~/.config/qtile'
   runuser -l $user -c '\cp -r tmp/qtile_config/wolf01.jpg ~/Images/'
   runuser -l $user -c 'cd ~ && rm -R -f tmp'
fi

echo "Configurando vim"
runuser -l $user -c 'wget https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
runuser -l $user -c 'mkdir -p ~/.vim/autoload'
runuser -l $user -c 'mv plug.vim ~/.vim/autoload/'


echo "Iniciando configuración de arranque"
runuser -l $user -c 'mkdir -p ~/bin'
mv startup.sh /home/$user/bin/
chown $user /home/$user/bin/startup.sh
runuser -l $user -c 'chmod +x ~/bin/startup.sh'

echo "Configurando rofi"
runuser -l $user -c 'mkdir -p ~/.config/rofi'
mv config.rasi /home/$user/.config/rofi
chown $user /home/$user/.config/rofi/config.rasi

if [ "${multimonitor,,}" = "si" ]
then
    chown $user $SCRIPT_DIR/screen-config.sh
    mv screen-config.sh /home/$user/bin/
    runuser -l $user -c 'chmod +x ~/bin/screen-config.sh'
    runuser -l $user -c 'sed -i "s/#os.system(home+\"/bin/screen-config.sh\")/os.system(home+\"/bin/screen-config.sh\")/" ~/.config/qtile/config.py'
    
if

echo "comenzando prueba de terminal virtual tty1"
grep -q 'case \$(tty) in /dev/tty1)' /home/$user/.bashrc

if [ $? -ne 0 ]
    then
        runuser -l $user -c 'echo -e "case \$(tty) in /dev/tty1)\n\tif [ \$(pgrep Xorg -c) -eq 0 ]\n\tthen\n\t\tstartx\n\tfi\nesac" >> .bashrc'
	echo "Configurada sesion de qtile en xorg"
fi

echo "Proceso de instalación finalizado"
exit
