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
    fish rclone rsync vim

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