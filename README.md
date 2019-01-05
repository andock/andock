[![Latest Release](https://img.shields.io/github/release/andock/andock.svg?style=flat-square)](https://github.com/andock/andock/releases/latest) [![Build Status](https://img.shields.io/travis/andock/andock.svg?style=flat-square)](https://travis-ci.org/andock/andock)

[![Setup Instructions](https://img.shields.io/badge/%E2%9A%99-%20Setup%20Instructions%20-blue.svg)](https://andock.readthedocs.io/en/latest/)
[![Gitter](https://img.shields.io/gitter/room/andock/community-support.svg)](https://gitter.im/andock/community-support?source=orgpage)

![alt text](docs/images/logo_circle.svg "andock")

# Andock CLI

The Andock command line toool is the heart of Andock.    

## New to Andock?
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
Andock inside Docksal:

Thin command line tool which install Andock and execute Andock inside the CLI container.  
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
  andock command reference   1.0.0

  connect                    Connect andock to andock server
  (.) ssh-add <ssh-key>      Add private SSH key <ssh-key> variable to the agent store.

  Server:                    
  server install             Install andock server.
  server update              Update andock server.
  server ssh-add             Add public ssh key to andock server.

  Project:                   
  config generate            Generate andock project configuration.

  Build:                     
  build                      Build deployment artifact
  build deploy               Build deployment artifact and pushes to artifact repository.
  build clean                Clean build caches.

  Environment:               
  environment deploy (deploy)  Deploy environment.
  environment up             Start services.
  environment test           Run UI tests. (Like behat, phantomjs etc.)
  environment stop           Stop services.
  environment rm             Remove environment.
  environment url            Print environment urls.
  environment ssh [--container] <command>  SSH into environment. Specify a differnt container than cli with --container <SERVICE>

  fin <command>              Fin remote control.

  Drush:                     
  drush generate-alias <version>  Generate drush alias (Default: Version 9.

  version (v, -v)            Print andock version. [v, -v] - prints short version
  alias                      Print andock alias.

  self-update                Update andock

```


## Contributing to andock
Check the [Contributing docs](CONTRIBUTING.md) on how to get involved or run tests on your local maschine.
