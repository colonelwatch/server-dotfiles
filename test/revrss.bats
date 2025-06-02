load test_helper


@test "check nginx is installed" {
    check_package nginx
}


@test "check cloudflared is installed" {
    check_package cloudflared
}


@test "check nginx is enabled and running" {
    check_service nginx
}


@test "check cloudflared is enabled and running" {
    check_service cloudflared
}


@test "download latest revrss feed" {
    wget https://www.revrss.com/newswires.xml
    rm newswires.xml
}
