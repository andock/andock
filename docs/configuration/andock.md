# Configuration  
The andock configuration file `.andock/andock.yml` contains provides a number of variables to configure the build and the deploy process. 
With [hooks](hooks.md) you can setup the build and deploy process.
You can generate basic configuration files with `fin andock config generate`

Configuration files overview:

| File name                  | Description |
|----------------------------|:------------|
| `andock.yml`            | Main configuration file.
| `andock.${branch}.yml`            | Branch specific configuration file. (optional)

To overwrite configuration for a specific environment you can add an branch specific andock.{{branch]].yml.

For example configure your production domain to the master environment `.andock/andock.master.yml`.
```
virtual_hosts:
  default: 
    virtual_host: "www.domain.com"
    container: web
```

### Base configuration:
 * ` project_name: ` The display name of this project. 
 * ` project_id:` The id of this project, which must be unique within an andock server.   
 * ` git_repository_path:` The git checkout repository.

### Virtual hosts:
A virtual host pattern describes how HTTP requests forwarded to container.
The `default` 
``` 
virtual_hosts:
  default: 
    virtual_host: "{{branch}}.www.domain.com"
    container: web
``` 

### Mounts:
Mounts describe writeable persistent volumes in the docker container.
Mounts are linked via volumes into the docker container.
``` 
mounts:
  files
    path: 'docroot/files'
```

### Additional docksal-local.env variables
You can pass any variable to the generated `docksal-local.env`

#### Samples:
```
docksal_env:
  DOCKSAL_STACK: acquia
``` 


!!! tip "Own template generation files?"
    To overwrite the generation templates you can define your own template files. Simple add `docksal_local_yml_path` or `docksal_local_env_path` to your `andock.yml`

