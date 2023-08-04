chsh -s /usr/bin/fish # change default shell to fish

fish -c "conda config --set auto_activate_base false" # disable conda auto-activation

mkdir Laptop
rclone config reconnect server_bak: --auto-confirm
rclone config reconnect laptop_bak: --auto-confirm
rclone copy server_bak: ~ -P --fast-list --checkers=32 --transfers=16
rclone copy laptop_bak: ~/Laptop -P --fast-list --checkers=32 --transfers=16

npm install node-red-contrib-smartnora # just add smartnora manually

# install conda envs
conda env create -f ~/Services/sec-edgar/environment.yml

# nodered config was contained in the rclone backup
sudo systemctl enable nodered
sudo systemctl start nodered