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
fin andock server:ssh-add "ssh-rsa AAAAB3NzaC1yc2EA ..."
```

#### Generate project configuration
```
fin andock config:generate
```
This will create some required config files and templates for init, build, test and update hooks. 
#### Build project (optional)
@TODO If you like to build your project and push it to target repository before you check it out on andock server.
[See](./build.md)
#### Initialize remote environment
```
fin andock fin init
```

#### Update remote environment  
```
fin andock fin update
```

#### Run tests
```
fin andock fin test
```

### Congratulations, the installation is finished!

### Read more:
* [CI server automation](ci.md)
### Example hook configurations:
1. [Drupal](../configuration/example-drupal-hooks.md)