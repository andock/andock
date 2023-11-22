[![Latest Release](https://img.shields.io/github/release/andock/andock.svg?style=flat-square)](https://github.com/andock/andock/releases/latest) [![Build Status](https://img.shields.io/travis/andock/andock.svg?style=flat-square)](https://travis-ci.org/andock/andock)

[![Setup Instructions](https://img.shields.io/badge/%E2%9A%99-%20Setup%20Instructions%20-blue.svg)](https://andock.readthedocs.io/en/latest/)
[![Gitter](https://img.shields.io/gitter/room/andock/community-support.svg)](https://gitter.im/andock/community-support?source=orgpage)

![alt text](docs/images/logo_circle.svg "andock")

# Andock CLI

The Andock command line tool is the heart of Andock.    

## New to Andock?
* [See documentation](https://andock.readthedocs.io/en/latest/)
* [15 minutes setup](https://andock.readthedocs.io/en/latest/getting-started/docksal/)
* [Drupal boilerplate project](https://github.com/andock/boilerplate-drupal8)

## Installation

Andock inside Docksal:

Thin command line tool which runs andock with `fin run-cli` (prefered)
```
    curl -sS https://raw.githubusercontent.com/andock/andock/master/install-andock-docksal | sh
```

Docksal addon:
```
    fin addon install andock
```

Standalone (not recommend): 
```
    curl -sS https://raw.githubusercontent.com/andock/andock/master/install-andock | sh
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
  Andock command reference   1.0.0

  Options:                   
  Andock supports all ansible-playbook options  

  Samples:                   
  -v, --verbose         verbose mode (-vvv for more, -vvvv to enable
                        connection debugging)  
  -e EXTRA_VARS, --extra-vars=EXTRA_VARS
                        set additional variables as key=value or YAML/JSON, if
                        filename prepend with @  

  Connection                 
  connect                    Connect andock to Andock server
  (.) ssh-add <ssh-key>      Add private SSH key <ssh-key> variable to the agent store.

  Server:                    
  server install             Install Andock server.
  server update              Update Andock server.
  server ssh-add             Add public ssh key to Andock server.

  Project:                   
  config generate            Generate project configuration.

  Build:                     
  build                      Build deployment artifact
  build push                 Build deployment artifact and pushes to artifact repository.
  build clean                Clean build caches.

  build deploy               Build deployment artifact, pushes to artifact repository and deploy it.

  Environment:               
  environment deploy (deploy)  Deploy environment.
  environment up             Start services.
  environment test           Run UI tests. (Like behat, phantomjs etc.)
  environment stop           Stop services.
  environment rm             Remove environment.
  environment letsencrypt    Update Let's Encrypt certificate.
  environment url            Print environment urls.
  environment ssh [--container] <command>  SSH into environment. Specify a differnt container than cli with --container <SERVICE>

  fin <command>              Fin remote control.

  Drush:                     
  drush generate-alias <version>  Generate drush alias (Default: 9)

  version (v, -v)            Print Andock version. [v, -v] - prints short version

  self-update                Update Andock

```

Manual Docker Build
------------------

docker login
docker build -t andockio/andock:VERSION .
docker push andockio/andock:VERSION


## Contributing to andock
Check the [Contributing docs](CONTRIBUTING.md) on how to get involved or run tests on your local maschine.
