AUX_BACKUP_DIR="/media/auxiliary/backup"

if [ ! -d "$AUX_BACKUP_DIR/server" -o ! -d "$AUX_BACKUP_DIR/laptop" ]; then
    # TODO: define how to recover either from the cloud or the cold storage drive
    echo "error: backup on auxilary drive is unavailable"
    exit 1
fi

cp -r "$AUX_BACKUP_DIR/server" ~
ln -s "$AUX_BACKUP_DIR/laptop" ~/Laptop

# just add smartnora manually
cd ~/.node-red && npm install node-red-contrib-smartnora && cd -

# install conda envs
source ~/miniconda3/etc/profile.d/conda.sh
conda env create -f ~/Services/sec-edgar/environment.yml
conda env create -f ~/Services/revrss-newswires/environment.yml

# nodered config was contained in the rclone backup
sudo systemctl enable nodered

# cloudfared secrets were contained in the rclone backup
sudo cloudflared service install
sudo systemctl enable cloudflared

# previous website state was contained in the rclone backup
ln -s /var/www/revrss.com ~/www.revrss.com
cp ~/Services/revrss-newswires/data/newswires.xml ~/www.revrss.com/newswires.xml
rsync --exclude='newswires.xml' -r ~/Services/revrss-website/_site/ ~/www.revrss.com/