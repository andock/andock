# Test Andock on a Cloud Box
## Cloud installation
The easiest way to test <b>Andock</b> is to create a cloud box on any cloud provider which supports Ubuntu and docker.

After that point a wildcard domain to your new server.

Please check [system requirements](system-requirements.md) before you setup the server.

After that check out [Andock demo project](https://github.com/andock/demo-project)
```
git clone https://github.com/andock/demo-project.git
```
... and fin init
```
cd demo-project
fin init
```
Now you should see Hello Andock when you open: `http://demo-project.docksal/`.

The Andock addon is already part of the demo project. To get an overview of all commands run `fin andock`

## Let's start with Andock.

### Connect
You must connect your project to the Andock server by running 

`fin andock connect default YOUR-DOMAIN.com`. 

Andock will create a connection with name default which points to your cloud box.

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
Use `{{branch}}.YOUR-DOMAIN.com` as virtual host pattern.
 
This will create all required config files and templates for init, build, test and update hooks. 

### Build and deploy
```
fin andock build deploy
```

## Congratulations, the installation is finished!

Now you can open `http://master.YOUR-DOMAIN.com` to check the deployed demo site.

To access the environment (cli) via ssh run:
```
fin andock environment ssh
```
### Build another branch
Checkout a new branch:

```
git checkout -b develop
```
and run: 

``` 
fin andock build deploy
```  

!!! tip "Install and enable Andock addon"
    The Andock addon is already installed in the demo project. Run `fin addon install andock` to install the addon and enable it with `fin andock enable` 
    

### Read more:
* [Andock configuration overview](../configuration/andock.md) 
* [Hooks overview](../configuration/hooks.md)
* [The build process](../configuration/build.md)
* [The deploy process](../configuration/environment.md)
* [CI server automation](../integrations/ci.md)
