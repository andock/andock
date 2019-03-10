# Test Andock on a cloud box
## Cloud installation
The easiest way to test <b>Andock</b> is to create a cloud box on any cloud provider which fulfills the [system requirements](system-requirements.md).

After starting the cloud box point a wildcard domain to the server or use a wildcard DNS Service like [sslip.io](https://sslip.io) to access the server.   

This setup instruction uses `demo-project.YOUR-IP.sslip.io` to access the server.
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
Now you have to connect your project to the Andock server by running 

`fin andock connect default demo-project.YOUR-IP.sslip.io`. 

Andock will create a connection named `default` which points to your cloud box.

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
Use `{{branch}}.demo-project.YOUR-IP.sslip.io` as virtual host pattern.
 
This will create all required config files and templates for init, build, test and update hooks. 

### Build and deploy
```
fin andock build deploy
```

## Congratulations, the deployment has finished!

Now you can open `http://master.demo-project.YOUR-IP.sslip.io` to check the deployed demo site.

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

Now open http://develop.demo-project.YOUR-IP.sslip.io to access the environment of the develop branch.


### Read more:
* [Andock configuration overview](../configuration/andock.md) 
* [Hooks overview](../configuration/hooks.md)
* [The build process](../configuration/build.md)
* [The deploy process](../configuration/environment.md)
* [CI server automation](../integrations/ci.md)
