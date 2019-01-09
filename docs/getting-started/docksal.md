# 5 minutes setup instruction

## Preperation
### Cloud installation
The easiest way to test <b>Andock</b> is to create a cloud box on any cloud provider wich supports Ubuntu and docker.

After that point a wildcard domain to your new server.

Please check [system requirements](system-requirements.md) before you setup the server.

### Test on Vagrant
You can test <b>Andock</b> with vagrant (works on linux and OSX):

```
 curl -sS https://raw.githubusercontent.com/andock/andock/master/tests/vagrant-test | sh
```
This will download and start a Vagrant file with ubuntu 18.04, and updates your /etc/hosts to point to the Virtualserver. 
You need to install Vagrant and Virtualbox first.

## Let's start.
### Install and enable the addon.
```
fin addon install andock
fin andock enable
```
This will add an <b>Andock</b> container to your `docksal-local.yml`.

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
This will create some required config files and templates for init, build, test and update hooks. 
Look [here for an overview of Andock configuration](../configuration/andock.md) and [here for more details about the hook configuration](../configuration/hooks.md) 

### Build 
```
fin andock build push
```
[Here you can find more details about the build process](../configuration/build.md)

### Create environment
```
fin andock environment deploy
```
[Here you can find more details about the deploy process](../configuration/environment.md)
## Congratulations, the installation is finished!

### Read more:
* [CI server automation](../integrations/ci.md)
### Example hook configurations:
1. [Drupal](../configuration/example-drupal-hooks.md)
