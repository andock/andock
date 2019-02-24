# Configuration  
The Andock configuration file `.andock/andock.yml` provides variables to configure the build and deploy processes. 

With [hooks](hooks.md) you can define what happens during a build and deployment.

You can generate essential configuration files with `fin andock config generate`
## Sample configuration file
```
# andock.yml (version: 1.0.0)

## The name of this project, which must be unique within a andock server.
project_name: "demo-drupal"
project_id: "mp4yqom"

## The virtual host configuration pattern.
virtual_hosts:
  default:
    virtual_host: "{{ branch }}.demo-drupal.dev.andock.ci"
    container: web
  varnish:
    virtual_host: "www.{{ branch }}.demo-drupal.dev.andock.ci"
    container: varnish

## The git checkout repository.
git_repository_path: https://github.com/andock/boilerplate-drupal8.git

## Mounts describe writeable persistent volumes in the docker container.
## Mounts are linked via volumes: into the docker container.
mounts:
  files:
    path: 'web/sites/default/files'

## Let's encrypt.
## Uncomment to enable let's encrypt certificate generation.
letsencrypt_enable: true
## Uncomment for production letsencrypt certificates.
letsencrypt_directory: "{{ letsencrypt_directory_staging }}"

## ansible build hooks.
## The hooks that will be triggered when the environment is built/initialized/updated.
hook_build_tasks: "{{project_path}}/.andock/hooks/build_tasks.yml"
hook_init_tasks: "{{project_path}}/.andock/hooks/init_tasks.yml"
hook_update_tasks: "{{project_path}}/.andock/hooks/update_tasks.yml"
hook_test_tasks: "{{project_path}}/.andock/hooks/test_tasks.yml"
```



## Detailed explanation 
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
Andock checks the virtual host configuration and generates one certificate for each host. 

To disable a certificate generation for a specific domain add `letsencrypt_enable: true` to the specifc virtual host.

Example: 
``` 
virtual_hosts:
  cli: 
    virtual_host: "{{branch}}.www.domain.com"
    container: cli
    letsencrypt_enable: false
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

# Environment specific configuration files:

To overwrite configuration for a specific environment, you can define a environment specific `andock.{branch}.yml` configuration file.
In this file you overwrite all variables from `.andock/andock.yml`.
For example, configure your production domain to the master environment `.andock/andock.master.yml`.
```
virtual_hosts:
  default: 
    virtual_host: "www.domain.com"
    container: web
```

!!! tip "Own template generation files?"
    To overwrite the generation templates, you can define your template files. Simple add `docksal_local_yml_path` or `docksal_local_env_path` to your `andock.yml`

