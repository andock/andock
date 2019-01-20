# 5 minutes setup instruction

## Preperation
### Cloud installation
The easiest way to test <b>Andock</b> is to create a cloud box on any cloud provider which supports Ubuntu and docker.

After that point a wildcard domain to your new server.

Please check [system requirements](system-requirements.md) before you setup the server.

### Test on Vagrant
You can test <b>Andock</b> with vagrant (works on linux and OSX):

```
 curl -sS https://raw.githubusercontent.com/andock/andock/master/tests/vagrant-test | sh
```
This will download and start a Vagrant file with ubuntu 18.04. 

## Let's start.
Check out [Andock demo project](https://github.com/andock/demo-project)
```
git clone https://github.com/andock/demo-project.git
```

### Connect
You must connect your project to the Andock server by running `fin andock connect`. You will be asked for the connection name and the domain of the new server.
If you leave the connection name empty, `default` will be used. [Here](../configuration/connections.md) you can find more details about connections.
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
If you use vagrant use `{{branch}}.demo-project.andock.local` as virtual host pattern.
 
This will create some required config files and templates for init, build, test and update hooks. 

### Build and deploy
```
fin andock build deploy
```

## Congratulations, the installation is finished!

!!! tip "Install and enable Andock addon"
    The Andock addon is already installed in the demo project. Run `fin addon install andock` to install the addon and enable it with `fin andock enable` 
    
    




### Read more:
* [Andock configuration overview](../configuration/andock.md) 
* [Hooks overview](../configuration/hooks.md)
* [The build process](../configuration/build.md)
* [The deploy process](../configuration/environment.md)
* [CI server automation](../integrations/ci.md)
