# 5 minutes setup instruction

## Preperation
The easiest way to test andock is to create a cloud box on aws or digital ocean etc. with ubuntu 16.04 or 18.04 and point an wildcard dns like *.dev.yourdomain.com to the server.

If you want to test on your local maschine you can use any virtual maschine with an ubuntu 16.04 or 18.04 image and add an host entry to your virtual. 


[See system requirements](/system-requirements.md) 
#### Install addon
```
fin addon install andock
```
#### Enable andock in your project
```
fin andock enable
```
#### Setup the andock server

```
fin andock connect
fin andock server install
```

#### Generate project configuration
```
fin andock config generate
```
This will create some required config files and templates for init, build, test and update hooks. 

#### Build 
```
fin andock build deploy
```
Here you can find more configuration options for the [build process](../configuration/build.md)

#### Deploy environment
```
fin andock environment deploy
```

### Congratulations, the installation is finished!

### Read more:
* [CI server automation](../integrations/ci.md)
### Example hook configurations:
1. [Drupal](../configuration/example-drupal-hooks.md)