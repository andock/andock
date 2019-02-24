# Configuration  
The Andock configuration file `.andock/andock.yml` provides some variables to configure the build and deploy processes. 

With [hooks](hooks.md) you can define what happens during a build and deployment.

You can generate essential configuration files with `fin andock config generate`

Configuration files:

| File name                  | Description |
|----------------------------|:------------|
| `andock.yml`            | Main configuration file
| `andock.${branch}.yml`            | Branch specific configuration file (optional)

To overwrite configuration for a specific environment, you can add a branch specific `andock.{branch}.yml`.

For example, configure your production domain to the master environment `.andock/andock.master.yml`.
```
virtual_hosts:
  default: 
    virtual_host: "www.domain.com"
    container: web
```

### Base configuration
 * ` project_name: ` The display name of this project. 
 * ` project_id:` The id of this project, which must be unique within an Andock server.   
 * ` git_repository_path:` The git checkout repository.

### Virtual hosts
A virtual host pattern describes how HTTP requests are forwarded to the container.

``` 
virtual_hosts:
  default: 
    virtual_host: "{{branch}}.www.domain.com"
    container: web
``` 

### Mounts
Mounts describe writable persistent volumes in the docker container.
Mounts are linked via volumes into the docker container.
``` 
mounts:
  files
    path: 'docroot/files'
```

### Let's encrypt
You can enable Let's encrypt certificate generation with:
```
letsencrypt_enable: true 
``` 


### Protected branches
To protect an environment from deletion add it as protected branch. 
``` 
prototected_branches:
  - master
  - test
```
 Default protected branches are master and test.

### Docksal configuration variables
You can pass any variable to the generated `docksal-local.env`.
This can be useful if you want to replace an docker image or any other container configuration.

```
docksal_env:
  CLI_IMAGE: bitnami/php-fpm:7.3 
``` 

!!! tip "Own template generation files?"
    To overwrite the generation templates, you can define your template files. Simple add `docksal_local_yml_path` or `docksal_local_env_path` to your `andock.yml`

