#!/bin/bash -e

source common.sh

# TODO: define how to recover either from the cloud or the cold storage drive
AUX_BACKUP_DIR="/media/auxiliary/backup"
COLD_DATA_DIR="/media/cold/data"

function load_backup_from_auxiliary {
    if [ ! -d "$AUX_BACKUP_DIR" ]; then
        echo "error: backup on auxilary drive is unavailable"
        return 1
    fi
    rsync -a "$AUX_BACKUP_DIR/server/" ~/
    ln -s -f "$AUX_BACKUP_DIR/laptop" ~/Laptop
}

function load_data_from_cold {
    if [ -d ~/Data ]; then
        return 0  # skip for now (TODO: implement the recovery for this case)
    fi

    if [ ! -d "$COLD_BACKUP_DIR" ]; then
        echo "error: data on cold drive is unavailable"
        return 1
    fi

    n_latest=$(ls -At "$COLD_BACKUP_DIR" | head -n 1)
    if [ -z "$n_latest" ]; then
        echo "error: no snapshot found for data on cold drive"
        return 1
    fi

    btrfs subvolume create ~/Data
    btrfs subvolume create ~/Data/.snapshots
    sudo chown root:root ~/Data/.snapshots

    rsync -a --exclude="/.snapshots" "$COLD_BACKUP_DIR/$n_latest/snapshot/" ~/Data
}

function reenable_rclone {
    sudo rclone config reconnect backup: --auto-confirm
    sudo rclone config reconnect data: --auto-confirm
}


load_backup_from_auxiliary
load_data_from_cold
reenable_rclone

# reenable snapper and backup
for s in $SNAPPER_SERVICES; do
    sudo systemctl enable "$s"
done
for s in $BACKUP_SERVICES; do
    sudo systemctl enable "$s"
done

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
if [ ! -f /etc/systemd/system/cloudflared.service ]; then
    sudo cloudflared service install
fi
sudo systemctl enable cloudflared

# previous website state was contained in the backup
ln -s -f /var/www/revrss.com ~/www.revrss.com
cp ~/Services/revrss-newswires/data/newswires.xml ~/www.revrss.com/newswires.xml
rsync --exclude='newswires.xml' -r ~/Services/revrss-website/_site/ ~/www.revrss.com/
