chsh -s /usr/bin/fish # change default shell to fish

fish -c "conda config --set auto_activate_base false" # disable conda auto-activation

mkdir Laptop
rclone config reconnect server_bak: --auto-confirm
rclone config reconnect laptop_bak: --auto-confirm
rclone copy server_bak: ~ -P --fast-list --checkers=32 --transfers=16
rclone copy laptop_bak: ~/Laptop -P --fast-list --checkers=32 --transfers=16

# just add smartnora manually
cd ~/.node-red && npm install node-red-contrib-smartnora && cd -

# install conda envs
source ~/miniconda3/etc/profile.d/conda.sh
conda env create -f ~/Services/sec-edgar/environment.yml
conda env create -f ~/Services/revrss-newswires/environment.yml

# nodered config was contained in the rclone backup
sudo systemctl enable nodered
sudo systemctl start nodered

# cloudfared secrets were contained in the rclone backup
sudo cloudflared service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared

# previous website state was contained in the rclone backup
ln -s /var/www/revrss.com ~/www.revrss.com
cp ~/Services/revrss-newswires/data/newswires.xml ~/www.revrss.com/newswires.xml
rsync --exclude='newswires.xml' -r ~/Services/revrss-website/_site/ ~/www.revrss.com/
sudo systemctl restart nginx