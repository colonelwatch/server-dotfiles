#!/bin/bash -e

AUX_BACKUP_DIR="/media/auxiliary/backup"

if [ ! -d "$AUX_BACKUP_DIR/server" -o ! -d "$AUX_BACKUP_DIR/laptop" ]; then
    # TODO: define how to recover either from the cloud or the cold storage drive
    echo "error: backup on auxilary drive is unavailable"
    exit 1
fi

rsync -a "$AUX_BACKUP_DIR/server/" ~/
ln -s -f "$AUX_BACKUP_DIR/laptop" ~/Laptop

# reenable snapper
sudo systemctl enable snapper-*.timer

# install conda envs
source ~/miniconda3/bin/activate && conda deactivate
conda env create -f ~/Services/sec-edgar/environment.yml
conda env create -f ~/Services/revrss-newswires/environment.yml

# nodered state was in the backup, but add smartnora manually
cd ~/.node-red
npm install node-red-contrib-smartnora
cd -
sudo systemctl enable nodered

# cloudfared secrets were in the backup
sudo cloudflared service install
sudo systemctl enable cloudflared

# previous website state was contained in the backup
ln -s -f /var/www/revrss.com ~/www.revrss.com
cp ~/Services/revrss-newswires/data/newswires.xml ~/www.revrss.com/newswires.xml
rsync --exclude='newswires.xml' -r ~/Services/revrss-website/_site/ ~/www.revrss.com/
