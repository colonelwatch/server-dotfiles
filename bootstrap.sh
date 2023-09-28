# <SETUP>

# check if pwd is ~/.dotfiles
if [ ! "$PWD" = "$HOME/.dotfiles" ]; then
    echo "Please run this script from the ~/.dotfiles directory."
    exit 1
fi

sudo mkdir -p --mode=0755 /usr/share/keyrings

# add cloudflared repo
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg > /dev/null
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared bookworm main' | sudo tee /etc/apt/sources.list.d/cloudflared.list

# add zram-generator repo
sudo wget https://nabijaczleweli.xyz/pgp.txt -O /etc/apt/keyrings/nabijaczleweli.asc
echo 'deb [signed-by=/etc/apt/keyrings/nabijaczleweli.asc] https://debian.nabijaczleweli.xyz bookworm main' | sudo tee -a /etc/apt/sources.list.d/zram-generator.list
echo 'deb-src [signed-by=/etc/apt/keyrings/nabijaczleweli.asc] https://debian.nabijaczleweli.xyz bookworm main' | sudo tee -a /etc/apt/sources.list.d/zram-generator.list

sudo apt update && sudo apt upgrade -y

# </SETUP>



# <ROOT>

# record wifi config from /etc/network/interfaces
SSID=$(sudo cat /etc/network/interfaces | grep wpa-ssid | sed 's/\twpa-ssid *//')
PSK=$(sudo cat /etc/network/interfaces | grep wpa-psk | sed 's/\twpa-psk *//')

# install NetworkManager and resolved (for mDNS features) and stop networking.service from using the wifi
sudo apt install -y network-manager systemd-resolved
sudo cat /etc/network/interfaces | head -8 > ./interfaces # prepare interfaces file without wifi config
cat ./interfaces | sudo tee /etc/network/interfaces
rm ./interfaces # remove interfaces file
sudo systemctl restart networking wpa_supplicant
sudo systemctl restart NetworkManager systemd-resolved
sudo nmcli radio wifi off
sudo nmcli radio wifi on
sleep 10 # wait for wifi to be ready

# connect it to the previously recorded wifi network
sudo nmcli device wifi connect "$SSID" password "$PSK"

sudo apt install -y \
    systemd-zram

# install config files
sudo cp -rvf --no-preserve=mode,ownership root/etc/* /etc/

# use the new config files
sudo update-grub
sudo systemctl restart systemd-logind
sudo systemctl restart NetworkManager

# prepare revrss website root
sudo mkdir /var/www/revrss.com
sudo chown kenny /var/www/revrss.com/
sudo chgrp kenny /var/www/revrss.com/
sudo chmod +x /var/www/revrss.com/
sudo ln -s /etc/nginx/sites-available/revrss /etc/nginx/sites-enabled/revrss
ln -s /var/www/revrss.com ~/www.revrss.com

# use the new nginx config
sudo unlink /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

# </ROOT>



# <USER>

sudo apt install -y \
    build-essential cloudflared curl fish htop mosquitto nginx pkg-config rclone ronn rsync vim

wget https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered
bash ./update-nodejs-and-nodered --confirm-install --skip-pi --no-init --node18
rm ./update-nodejs-and-nodered

# download and execute miniconda install script
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3_install.sh
bash ~/miniconda3_install.sh -b # conda will soon be intialized by importing the fish config
rm ~/miniconda3_install.sh

# install config files
mkdir -p ~/.config
ln -s -f $PWD/config/* ~/.config/

# deal with rclone config edge case
unlink ~/.config/rclone # undo symlink b/c it eventually contains keys we don't want to commit...
mkdir ~/.config/rclone  #  ...so we'll only copy the config files
cp ~/.dotfiles/config/rclone/rclone.conf ~/.config/rclone/
# rclone is not authorized yet, so authorize manually in recovery.sh

# other config
crontab crontab.bak

# </USER>



# <CLEANUP>

# </CLEANUP>