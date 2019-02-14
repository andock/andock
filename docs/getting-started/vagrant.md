# Test Andock with Vagrant (works on linux and OSX):

## Preperation
To use vagrant, a supported hyperviser needs to be installed as well as vagrant itself. 

The easiest setup to start with is to install Virtualbox via your system’s package manager. 


### Install Ubuntu 18.04 with Vagrant
To easily setup an Vagrant box run:
```
 curl -sS https://raw.githubusercontent.com/andock/andock/master/tests/vagrant-test | sh
```
This starts an Ubunutu 18.04 and adds your private key file and don't forget to copy the host entries to your host file.

### Check out and initialize the demo project
Check out [Andock demo project](https://github.com/andock/demo-project)
```
git clone https://github.com/andock/demo-project.git
```
... and fin init
```
cd demo-project
fin init
```
Now you should see Hello Andock when you open: `http://demo-project.docksal/`
and you shoud connect to the Vagrant machine with `root@192.168.33.10` 

The Andock addon is already part of the demo project. To get an overview of all commands run `fin andock`
#### The setup of the test environment is done!

## Let's start with Andock.
  
### Connect
You must connect your project to the Andock server by running 

`fin andock connect default andock.vagrant`. 

Andock will create a connection with name default which points to your vagrant box.

[Here](../configuration/connections.md) you can find more details about connections.

```
fin andock connect
```
### Install Andock server
Andock needs Docksal installed on the server. You can easily install Docksal with: 
```
fin andock server install
```
### Generate project configuration
```
fin andock config generate
```
Use `{{branch}}.demo-project.andock.vagrant` as virtual host pattern.
 
This will create some required config files and templates for init, build, test and update hooks. 

### Build and deploy
```
fin andock build deploy
```
Now you can open `master.demo-project.andock.vagrant` to check the deployed demo site.

If you want to create an new environment for branch `develop` simple run `git checkout -b develop` and than `fin andock build deploy`  

## Congratulations, the installation is finished!

!!! tip "Install and enable Andock addon"
    The Andock addon is already installed in the demo project. Run `fin addon install andock` to install the addon and enable it with `fin andock enable` 
    
    




### Read more:
* [Andock configuration overview](../configuration/andock.md) 
* [Hooks overview](../configuration/hooks.md)
* [The build process](../configuration/build.md)
* [The deploy process](../configuration/environment.md)
* [CI server automation](../integrations/ci.md)
