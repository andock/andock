# 5 minutes setup instruction


[System requirements](/system-requirements.md)
#### Install addon
```
fin addon install andock
```
#### Enable andock in your project
```
fin andock enable
```
#### Setup the andock server
The easiest way to test andock is to create a cloud box on aws or digital ocean etc. with ubuntu 16.04 or 18.04.

After that run:

```
fin andock connect
fin andock server:install
```

#### Generate project configuration
```
fin andock config:generate
```
This will create some required config files and templates for init, build, test and update hooks. 

#### Build 
```
fin andock build
```
Here you can find more configuration options for the [build process](../configuration/build.md)
#### Deploy 
```
fin andock deploy
```

### Congratulations, the installation is finished!

### Read more:
* [CI server automation](../integrations/ci.md)
### Example hook configurations:
1. [Drupal](../configuration/example-drupal-hooks.md)