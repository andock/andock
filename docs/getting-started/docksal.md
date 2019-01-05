# 5 minutes setup instruction

## Preperation
### Cloud installation
The easiest way to test Andock is to create a cloud box on any cloud wich supports Ubuntu and docker.

After that point an wildcard domain to your new server.

Please check [system requirements](system-requirements.md) before setup the server.

### Test on Vagrant
You can test <b>Andock</b> with vagrant (works on linux and macss):

```
 curl -sS https://raw.githubusercontent.com/andock/andock/master/tests/vagrant-test | sh
```
This will download and start a Vagrant file with ubuntu 18.04, and updates your /etc/hosts to point the Virtualserver. 
You need to install Vagrant and Virtualbox first.

## Let's start.
### Install the and enable the addon.
```
fin addon install andock
fin andock enable
```
This will add an <b>Andock</b> container to your `docksal-local.yml`.

### Connect
You must connect your project to the Andock server by running `fin andock connect`. You will be asked for the connection name and the domain of the new server.
As connection name just hit enter. `default` will than be used as connection name. [Here](../configuration/connections.md) you find more details about connections.
```
fin andock connect
```
### Install Andock server
Andock needs Docksal installed on the server. You can easily install docksal with: 
```
fin andock server install
```
### Generate project configuration
```
fin andock config generate
```
This will create some required config files and templates for init, build, test and update hooks. 
Here you will find an overview of Andock [configuration](../configuration/andock.md). And here you will find more details about the [hook configuration](../configuration/hooks.md) 

### Build 
```
fin andock build deploy
```
Here you find more details about the [build process](../configuration/build.md)

### Create environment
```
fin andock environment deploy
```
Here you find more details about [deploy process](../configuration/environment.md)
## Congratulations, the installation is finished!

### Read more:
* [CI server automation](../integrations/ci.md)
### Example hook configurations:
1. [Drupal](../configuration/example-drupal-hooks.md)