load test_helper

@test "download latest revrss feed" {
    wget https://www.revrss.com/newswires.xml
    rm newswires.xml
}
