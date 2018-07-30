# 5 minutes setup instruction


[System requirements](/system-requirements.md)
#### Install addon
```
fin addon install acp
```
#### Enable acp in your project
```
fin acp enable
```
#### Setup the acp server
The easiest way to test andock is to create a cloud box on aws or digital ocean etc. with ubuntu 16.04 or 18.04.

After that run:

```
fin acp connect
fin acp server:install
fin acp server:ssh-add "ssh-rsa AAAAB3NzaC1yc2EA ..."
```

#### Generate project configuration
```
fin acp config:generate
```
This will create some required config files and templates for init, build, test and update hooks. 
#### Build project (optional)
@TODO If you like to build your project and push it to target repository before you check it out on andock server.
[See](./build.md)
#### Initialize remote environment
```
fin acp fin init
```

#### Update remote environment  
```
fin acp fin update
```

#### Run tests
```
fin acp fin test
```

### Congratulations, the installation is finished!

### Read more:
* [CI server automation](ci.md)
### Example hook configurations:
1. [Drupal](../configuration/example-drupal-hooks.md)