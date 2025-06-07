SNAPPER_SERVICES=$(cat <<EOF
snapper-cleanup.timer
snapper-timeline.timer
snapper-boot.timer
EOF
)

BACKUP_SERVICES=$(cat <<EOF
archive-snapshots.service
backup-permissions.service
backup-server.service
upload-snapshots.service
archive-snapshots.service
EOF
)
