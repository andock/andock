[![Latest Release](https://img.shields.io/github/release/andock/server.svg?style=flat-square)](https://github.com/andock/andock/releases/latest) [![Build Status](https://img.shields.io/travis/andock/server.svg?style=flat-square)](https://travis-ci.org/andock/server)

andock server.
=========

**andock.server** is a Ansible role which:
* Create Andock user and setup user permissions
* Install and updates Docksal in sandbox mode 
* Install andockio/ssh2docksal
  

Requirements
------------

In order to build your apps with Andock CI, you will need:

* Ansible in your deploy machine

Installation
------------

Andock is an Ansible role distributed globally using [Ansible Galaxy](https://galaxy.ansible.com/). In order to install andock role you can use the following command.

```
$ ansible-galaxy install andock.fin
```

Update
------

If you want to update the role, you need to pass **--force** parameter when installing. Please, check the following command:

```
$ ansible-galaxy install --force andock.fin
```


License
-------

GPL

Author Information
------------------

Christian Wiedemann (christian.wiedemann@key-tec.de)
