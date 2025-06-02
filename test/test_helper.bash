load "/usr/lib/bats/bats-support/load"
load "/usr/lib/bats/bats-assert/load"
load "/usr/lib/bats/bats-file/load"


function check_package {
    package="$1"

    run dpkg-query -Wf '${db:Status-abbrev}' "$package"
    assert_success
    assert_output --partial "ii"  # NOTE: full match gives a false negative
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
