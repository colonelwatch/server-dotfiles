load test_helper


@test "check snapper is installed" {
    check_package snapper
}


@test "check snapper-cleanup.timer is enabled and running" {
    check_service snapper-cleanup.timer
}


@test "check snapper-timeline.timer is enabled and running" {
    check_service snapper-timeline.timer
}


@test "check snapper-boot.timer is enabled and running" {
    check_service snapper-boot.timer
}


@test "find snapper config \"backup\"" {
    run snapper list-configs --columns config
    assert_success
    assert_line "backup"
}


@test "find and validate backup subvolume" {
    # NOTE: checks for a directory, not a btrfs subvolume, but that needs sudo
    BACKUP_DIR="/media/auxiliary/backup"
    SNAPSHOTS_DIR="$BACKUP_DIR/.snapshots"
    assert_dir_exists "$BACKUP_DIR"
    assert_dir_exists "$SNAPSHOTS_DIR"
    assert_file_owner root "$SNAPSHOTS_DIR"
    assert_regex $(stat -c '%A' "$SNAPSHOTS_DIR") 'drwx.-..-.'
}


@test "check backup scripts exist and are executable" {
    for f in backup-permissions backup-server restore-permissions upload-snapshots; do
        l="/usr/bin/$f"
        t="$PWD/root/usr/bin/$f"
        assert_symlink_to "$t" "$l"
        assert_file_executable "$t"
    done
}


@test "check backup-permissions is enabled" {
    check_service backup-permissions
}


@test "check backup-server is enabled" {
    check_service backup-server
}


@test "check upload-snapshots is enabled" {
    check_service upload-snapshots
}
