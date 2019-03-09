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

To access the virtual box and to leave your /etc/hosts untouched the setup sample uses the wildcard DNS Service [sslip.io](sslip.io).

With sslip.io you can ping the virtual box with `ping demo-project.192-168-33-10.sslip.io`.

You should also be able to connect to the Vagrant machine with `ssh root@demo-project.192-168-33-10.sslip.io`.

### Prepare the demo project
Check out [Andock demo project](https://github.com/andock/demo-project)
```
git clone https://github.com/andock/demo-project.git
```
... and run fin init
```
cd demo-project
fin init
```
Now you should see __Welcome to Andock__ when you open: `http://demo-project.docksal/`

#### The setup of the local Docksal environment is done!

## Let's start with Andock.
### First install and activate the Andock addon
```
fin addon install andock
```
### Connect
Connect your project to the Andock server by running: 

```
fin andock connect default demo-project.192-168-33-10.sslip.io
```

Andock will create a connection with name default which points to your vagrant box.

[Here](../configuration/connections.md) you can find more details about connections.

### Prepare Andock server
Andock needs Docksal installed on the server. Simple run: 
```
fin andock server install
```
### Generate project configuration
```
fin andock config generate
```
Use `{{branch}}.demo-project.192-168-33-10.sslip.io` as virtual host pattern.
 
This will create all required config files and templates for init, build, test and update hooks. 

### Build and deploy
The last step ist build and deploy the demo application. Run:
```
fin andock build deploy
```

## Congratulations, the deployment has finished!
Now open [http://master.demo-project.192-168-33-10.sslip.io](http://master.demo-project.192-168-33-10.sslip.io) to check the deployed demo site.

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
Now open [http://develop.demo-project.192-168-33-10.sslip.io](http://develop.demo-project.192-168-33-10.sslip.io) to access the environment of the develop branch.
### Read more:
* [Andock configuration overview](../configuration/andock.md) 
* [Hooks overview](../configuration/hooks.md)
* [The build process](../configuration/build.md)
* [The deploy process](../configuration/environment.md)
* [CI server automation](../integrations/ci.md)
