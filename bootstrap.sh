# <SETUP>

# check if pwd is ~/.dotfiles
if [ ! "$PWD" = "$HOME/.dotfiles" ]; then
    echo "Please run this script from the ~/.dotfiles directory."
    exit 1
fi

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

# install config files
sudo cp -rvf --no-preserve=mode,ownership root/etc/* /etc/

# use the new config files
sudo update-grub
sudo systemctl restart systemd-logind
sudo systemctl restart NetworkManager

# </ROOT>



# <USER>

sudo apt install -y \
    build-essential curl fish htop mosquitto nginx pkg-config rclone ronn rsync vim

wget https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered
bash ./update-nodejs-and-nodered --confirm-install --skip-pi --no-init --node18
rm ./update-nodejs-and-nodered

# download and execute rust install script
wget https://sh.rustup.rs -O ~/rustup-init.sh
bash ~/rustup-init.sh -y
rm ~/rustup-init.sh
export PATH="$HOME/.cargo/bin:$PATH" # TODO: add cargo to path in fish config

# download and move go binary
wget https://go.dev/dl/go1.20.8.linux-amd64.tar.gz -O go.tar.gz
sudo tar -C /usr/local -xzf go.tar.gz
export PATH="$PATH:/usr/local/go/bin" # TODO: add go to path in fish config
rm ~/go.tar.gz

# download and execute miniconda install script
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3_install.sh
bash ~/miniconda3_install.sh -b # conda will soon be intialized by importing the fish config
rm ~/miniconda3_install.sh

# compile and install zram-generator
git clone https://github.com/systemd/zram-generator ~/zram-generator
cd ~/zram-generator && make build && sudo make install NOBUILD=true && cd -
rm -rf ~/zram-generator
sudo systemctl daemon-reload
sudo systemctl start /dev/zram0 # TODO: drop the swap partition that comes with Debian

# compile and install cloudflared
git clone https://github.com/cloudflare/cloudflared.git
cd cloudflared && make cloudflared && go install github.com/cloudflare/cloudflared/cmd/cloudflared && cd -

# install config files
mkdir -p ~/.config
ln -s -f $PWD/config/* ~/.config/

# deal with rclone config edge case
unlink ~/.config/rclone # undo symlink b/c it eventually contains keys we don't want to commit...
mkdir ~/.config/rclone  #  ...so we'll only copy the config files
cp ~/.dotfiles/config/rclone/rclone.conf ~/.config/rclone/
# rclone is not authorized yet, so authorize manually in recovery.sh

# deal with nginx edge case
sudo chmod +x /home
sudo chmod +x /home/kenny
sudo chmod +x /home/kenny/www
sudo chmod +x /home/kenny/www/revrss
sudo unlink /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/revrss /etc/nginx/sites-enabled/revrss
sudo systemctl restart nginx

# other config
crontab crontab.bak

# </USER>



# <CLEANUP>

# </CLEANUP>