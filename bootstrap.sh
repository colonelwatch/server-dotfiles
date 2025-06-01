function do_setup {
    # install curl, get add cloudflare gpg key
    sudo apt install -y curl
    sudo mkdir -p --mode=0755 /usr/share/keyrings
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg |         \
        sudo tee /usr/share/keyrings/cloudflare-main.gpg > /dev/null

    # configure apt
    sudo cp -rvf --no-preserve=mode,ownership root/etc/apt/* /etc/apt/

    sudo apt update && sudo apt upgrade -y
}


function do_networking {
    if dpkg-query -Wf'${db:Status-abbrev}' network-manager | grep -q '^i'; then
        return 0  # network-manager is already installed, so skip
    fi

    # install packages for NetworkManager and resolved (for mDNS features)
    sudo apt install -y network-manager systemd-resolved

    # record wifi config from /etc/network/interfaces
    ssid=$(sudo cat /etc/network/interfaces | grep wpa-ssid | sed 's/\twpa-ssid *//')
    psk=$(sudo cat /etc/network/interfaces | grep wpa-psk | sed 's/\twpa-psk *//')

    # delete wifi config, thus giving control from networking.service to NetworkManager
    temp=$(mktemp)
    sudo cat /etc/network/interfaces | head -8 > "$temp"
    sudo mv "$temp" /etc/network/interfaces

    # Apply transition by stopping and disabling networking.service and then restarting
    # NetworkManager (resolved and NetworkManager are already enabled upon install)
    sudo systemctl disable networking
    sudo systemctl stop networking
    sudo systemctl restart systemd-resolved wpa_supplicant  # first, dependencies of NM
    sudo systemctl restart NetworkManager

    # connect it to the previously recorded wifi network
    sleep 10 # wait for wifi to be ready
    sudo nmcli device wifi connect "$ssid" password "$psk"
}


function do_revrss_website {
    if [ -d /var/www/revrss.com ]; then
        return 0  # skip, since this step is already done
    done

    # prepare revrss website root
    sudo mkdir /var/www/revrss.com
    sudo chown kenny /var/www/revrss.com/
    sudo chgrp kenny /var/www/revrss.com/
    sudo chmod +x /var/www/revrss.com/
    sudo ln -s /etc/nginx/sites-available/revrss /etc/nginx/sites-enabled/revrss
    ln -s /var/www/revrss.com ~/www.revrss.com

    # use the new nginx config
    sudo unlink /etc/nginx/sites-enabled/default
}


function do_root {
    do_networking

    # install packages, utilities, and scripts
    sudo apt install -y \
        bolt btrfs-progs cloudflared firmware-misc-nonfree nvidia-driver mosquitto  \
        nginx snapper systemd-zram-generator
    sudo apt install -y \
        acl build-essential ffmpeg fish htop parallel pkg-config rclone ronn rsync  \
        ruby-full screen vim
    sudo ln -s -f root/usr/bin/* /usr/bin/

    # install config files, including service files
    sudo cp -rvf --no-preserve=mode,ownership root/etc/* /etc/
    sudo systemctl daemon-reload  # immediately use the service files

    # enable services for the next boot
    sudo systemctl enable backup-server
    sudo systemctl enable backup-permissions
    sudo systemctl enable upload-snapshots

    # other setup
    sudo update-grub  # grub needs to be further applied
    do_revrss_website
}


# check if pwd is ~/.dotfiles
if [ ! "$PWD" = "$HOME/.dotfiles" ]; then
    echo "Please run this script from the ~/.dotfiles directory."
    exit 1
fi

do_setup
do_root



# <USER>

wget https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered
bash ./update-nodejs-and-nodered --confirm-install --skip-pi --no-init --node18
rm ./update-nodejs-and-nodered

# download and execute miniconda install script
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3_install.sh
bash ~/miniconda3_install.sh -b # conda will soon be intialized by importing the fish config
rm ~/miniconda3_install.sh

# install jekyll and bundler
GEM_HOME="$HOME/gems" PATH="$HOME/gems/bin:$PATH" gem install jekyll bundler

# install config files
mkdir -p ~/.config
ln -s -f config/* ~/.config/

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