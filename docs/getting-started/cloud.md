# Test Andock on a cloud box
## Cloud installation
The easiest way to test <b>Andock</b> is to create a cloud box on any cloud provider which fulfills the [system requirements](system-requirements.md).

Point a wildcard domain to your new server and check out the [Andock demo project](https://github.com/andock/demo-project) on your local machine.
```
git clone https://github.com/andock/demo-project.git
```
... and fin init
```
cd demo-project
fin init
```
Now you should see __Welcome to Andock__ when you open: `http://demo-project.docksal/`.


## Let's start with Andock.

### Connect
Now you have to connect your project to the Andock server by running 

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

## Congratulations, the deployment has finished!

Now you can open `http://master.YOUR-DOMAIN.com` to check the deployed demo site.

To access the environment (cli) via ssh run:
```
fin andock environment ssh
```
### Build the dev branch
Now create your first a dev branch and build the dev environment:

```
git fetch origin develop
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
