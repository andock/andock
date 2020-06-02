import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    '.molecule/ansible_inventory').get_hosts('all')


def test_number_of_keys(File, Sudo):
    f_root = File('/root/.ssh/authorized_keys')
    f_johnd = File('/home/johnd/.ssh/authorized_keys')
    root_keys = sum(1 for line in f_root.content_string.splitlines())
    johnd_keys = sum(1 for line in f_johnd.content_string.splitlines())

    assert f_root.exists
    assert f_root.contains('ssh-rsa KKKKB3NzaC1yc2EAAAADAQABAAABAQDmttIEinXN5+2J8g3V3XnVRshX9qllMNbHqGNT9x7glW5PsG1XUAKIjIvD5GfTEbqjxHuCuxXUuoUi/LsrQAGUO1hEnamsDZtczhWmoHiK8gzLW83qKIzXLsGEexzi7POnroRvjKNy2/koeigjY3+GcRXsJzwv0P4IaJMLi/aDvOhzLe00yiNQ6X+9Fdyp3n589e3k5H+A9BqROanoxuAA7ko0TGW52AHxM51doEofy4ySKqOj3M+vV5VwQNFmUFqa8WEnBYZ6k5eUL4ixJxY5TMzZfzWcOpIhI8+8WrnTmsDIB3t54VO3BeVW5hrG8W6oiwDVDvSDTpqklY2gmwI7')  # noqa: E501
    assert root_keys == 3
    assert f_johnd.exists
    assert f_johnd.contains('ssh-rsa BBBBB3NzaC1yc2EAAAADAQABAAABAQDmttIEinXN5+2J8g3V3XnVRshX9qllMNbHqGNT9x7glW5PsG1XUAKIjIvD5GfTEbqjxHuCuxXUuoUi/LsrQAGUO1hEnamsDZtczhWmoHiK8gzLW83qKIzXLsGEexzi7POnroRvjKNy2/koeigjY3+GcRXsJzwv0P4IaJMLi/aDvOhzLe00yiNQ6X+9Fdyp3n589e3k5H+A9BqROanoxuAA7ko0TGW52AHxM51doEofy4ySKqOj3M+vV5VwQNFmUFqa8WEnBYZ6k5eUL4ixJxY5TMzZfzWcOpIhI8+8WrnTmsDIB3t54VO3BeVW5hrG8W6oiwDVDvSDTpqklY2gmwI7')  # noqa: E501
    assert f_johnd.contains('ssh-rsa KKKKB3NzaC1yc2EAAAADAQABAAABAQDmttIEinXN5+2J8g3V3XnVRshX9qllMNbHqGNT9x7glW5PsG1XUAKIjIvD5GfTEbqjxHuCuxXUuoUi/LsrQAGUO1hEnamsDZtczhWmoHiK8gzLW83qKIzXLsGEexzi7POnroRvjKNy2/koeigjY3+GcRXsJzwv0P4IaJMLi/aDvOhzLe00yiNQ6X+9Fdyp3n589e3k5H+A9BqROanoxuAA7ko0TGW52AHxM51doEofy4ySKqOj3M+vV5VwQNFmUFqa8WEnBYZ6k5eUL4ixJxY5TMzZfzWcOpIhI8+8WrnTmsDIB3t54VO3BeVW5hrG8W6oiwDVDvSDTpqklY2gmwI7')  # noqa: E501
    assert johnd_keys == 4
