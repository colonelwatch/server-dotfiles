load test_helper


function check_package {
    package="$1"

    run dpkg-query -Wf '${db:Status-abbrev}' "$package"
    assert_success
    assert_output --partial "ii"  # NOTE: full match gives a false negative
}


@test "check NetworkManager is installed" {
    check_package network-manager
}


@test "check resolved is installed" {
    check_package systemd-resolved
}


function check_service {
    service="$1"

    run systemctl is-enabled "$service"
    assert_success
    assert_output "enabled"

    run systemctl show "$service"
    assert_success
    assert_line "ActiveState=active"
    assert_line "SubState=running"
}


@test "check wpa_supplicant is enabled and running" {
    check_service wpa_supplicant
}


@test "check resolved is enabled and running" {
    check_service systemd-resolved
}


@test "check NetworkManager is enabled and running" {
    check_service NetworkManager
}


@test "check WiFi connection was established in NetworkManager" {
    run nmcli connection
    assert_success
    assert_line --partial "wifi"
}
