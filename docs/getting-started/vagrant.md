# Test Andock with Vagrant (works on linux and OSX):

## Preparation
To use vagrant, a supported hypervisor needs to be installed as well as vagrant itself. 

The easiest setup to start with is to install Virtualbox via your system’s package manager. 


### Install Ubuntu 18.04 with Vagrant
To quickly set up a Vagrant box run:
```
 curl -sS https://raw.githubusercontent.com/andock/andock/master/tests/vagrant-test | bash
```
The test script will ask you for your public key file to add it to the authorized_keys file on the vagrant box.

After the installation, the script will ask you to copy the three domains to your /etc/hosts. With these domains you can access the deployed page. 

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
Now you should see 'Welcome to Andock' when you open: `http://demo-project.docksal/`
and you should be able to connect to the Vagrant machine with `ssh root@192.168.33.10` 

The Andock addon is already part of the demo project. To get an overview of all commands run `fin andock`
#### The setup of the test environment is done!

## Let's start with Andock.
  
### Connect
Connect your project to the Andock server by running: 

```
fin andock connect default andock.vagrant
```

Andock will create a connection with name default which points to your vagrant box.

[Here](../configuration/connections.md) you can find more details about connections.

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
 
This will create all required config files and templates for init, build, test and update hooks. 

### Build and deploy
```
fin andock build deploy
```

## Congratulations, the deployment has finished!
Now open [http://master.demo-project.andock.vagrant](http://master.demo-project.andock.vagrant) to check the deployed demo site.

To access the environment (cli) container via ssh run:
```
fin andock environment ssh
```
### Build the dev branch
Now create your first dev branch and build the dev environment:

```
git fetch origin develop
git checkout -b develop

```
and run: 

``` 
fin andock build deploy
```  

!!! tip "Install and enable Andock addon"
    The Andock addon is part of the demo project. Run `fin addon install andock` to install the addon and enable it with `fin andock enable` 
    

### Read more:
* [Andock configuration overview](../configuration/andock.md) 
* [Hooks overview](../configuration/hooks.md)
* [The build process](../configuration/build.md)
* [The deploy process](../configuration/environment.md)
* [CI server automation](../integrations/ci.md)
