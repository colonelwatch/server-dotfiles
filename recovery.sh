chsh -s /usr/bin/fish # change default shell to fish

mkdir Laptop
rclone config reconnect server_bak: --auto-confirm
rclone config reconnect laptop_bak: --auto-confirm
rclone copy server_bak: ~ -P --fast-list --checkers=32 --transfers=16
rclone copy laptop_bak: ~/Laptop -P --fast-list --checkers=32 --transfers=16
