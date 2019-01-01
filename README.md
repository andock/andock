[![Latest Release](https://img.shields.io/github/release/andock/andock.svg?style=flat-square)](https://github.com/andock/andock/releases/latest) [![Build Status](https://img.shields.io/travis/andock/andock.svg?style=flat-square)](https://travis-ci.org/andock/andock)

[![Setup Instructions](https://img.shields.io/badge/%E2%9A%99-%20Setup%20Instructions%20-blue.svg)](https://andock.readthedocs.io/en/latest/)
[![Gitter](https://img.shields.io/gitter/room/andock/community-support.svg)](https://gitter.im/andock/community-support?source=orgpage)

![alt text](docs/images/logo_circle.svg "andock")

# andock cli - develop in docksal, deploy with docksal.

The `andock cli` is a command line interface to andock.    

## New to andock?
* [See documentation](https://andock.readthedocs.io/en/latest/)
* [5 minutes setup](https://andock.readthedocs.io/en/latest/getting-started/docksal/)
* [Drupal boilerplate project](https://github.com/andock/boilerplate-drupal8)
## Installation
Docksal addon (prefered):
```
    fin addon install andock
```
Standalone: 
```
    curl -sS https://raw.githubusercontent.com/andock/andock/master/install-andock | sh
```
Andock inside docksal:

Thin command line tool which install andock and execute andock inside the cli container.  
```
    curl -sS https://raw.githubusercontent.com/andock/andock/master/install-andock-docksal | sh
```


## Updates
Update with this command:
```
    andock self-update
```

## Usage
As docksal addon:
```
    fin andock help
```
Standalone: 
```
    andock help
```

Andock inside docksal:
```
    andock help
```

# Commands:
```bash
  andock command reference   0.0.5
 
   connect                    Connect andock to andock server
   (.) ssh-add <ssh-key>      Add private SSH key <ssh-key> variable to the agent store.
 
   Server management:         
   server install             Install andock server.
   server update              Update andock server.
   server ssh-add             Add public ssh key to andock server.
 
   Project configuration:     
   config generate            Generate andock project configuration.
 
   Build management:          
   build                      Build the current project.
 
   Environment management:    
   environment deploy (deploy)  Deploy environment.
   environment up             Start services.
   environment test           Run UI tests. (Like behat, phantomjs etc.)
   environment stop           Stop services.
   environment rm             Remove environment.
   environment url            Print environment urls.
 
   fin <command>              Fin remote control.
 
   Drush:                     
   drush generate-alias       Generate drush alias.
 
   version (v, -v)            Print andock version. [v, -v] - prints short version
   alias                      Print andock alias.
 
   self-update                Update andock

```


## Contributing to andock
Check the [Contributing docs](CONTRIBUTING.md) on how to get involved or run tests on your local maschine.
