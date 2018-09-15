![alt text](docs/images/logo_circle.svg "andock")

# andock cli - docksal and ansible powered hosting.

The `andock cli` is a command line interface to andock.    

## New to andock?
* [See documentation](https://andock.readthedocs.io/en/latest/)
* [5 minutes setup](https://andock.readthedocs.io/en/latest/getting-started/docksal/)

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
 andock command reference   0.0.4

  connect                    Connect andock to andock server
  (.) ssh-add <ssh-key>      Add private SSH key <ssh-key> variable to the agent store.

  Server management:         
  server:install [root_user, default=root] [andock_pass, default=keygen]  Install andock server.
  server:update [root_user, default=root]  Update andock server.
  server:ssh-add [root_user, default=root]  Add public ssh key to andock server.

  Project configuration:     
  generate:config            Generate andock project configuration.

  Project build management:  
  build                      Build project and push it to artifact repository.

  Environment management:    
  deploy                     Deploy environment.
  up                         Start services.
  test                       Run UI tests. (Like behat, phantomjs etc.)
  stop                       Stop services.
  rm                         Remove environment.

  fin <command> <path>       Run any fin command.

  Drush:                     
  drush:generate-alias       Generate drush alias.

  version (v, -v)            Print andock version. [v, -v] - prints short version
  alias                      Print andock alias.

  self-update                Update andock
```


## Contributing to andock
Check the [Contributing docs](CONTRIBUTING.md) on how to get involved or run tests on your local maschine.
