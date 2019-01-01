# Configuration  
The following configuration files are added to the project by running `fin acp generate:config`

Andock generates `docksal-local.env` and `docksal-local.yml` files based on ansible templates and configuration parameters.

Here is a short overview of the used configuration files:

| File name                  | Description |
|----------------------------|:------------|
| `andock.yml`            | Main configuration file.
| `andock.${branch}.yml`            | Branch specific configuration file. (optional)
| `hooks/build_tasks.yml`    | Build hook fired while `fin andock build`. |
| `hooks/init_tasks.yml`     | Build hook fired while `fin andock fin init, fin andock deploy` |
| `hooks/update_tasks.yml`   | Build hook fired while `fin andock fin update, fin andock deploy`|
| `hooks/test_tasks.yml`     | Build hook fired while `fin andock fin test`|

## The andock configuration file `.andock/andock.yml`:

### Base configuration:
 * ` project_name: ` The display name of this project. 
 * ` project_id:` The id of this project, which must be unique within an andock server. This id used for folder names etc.  
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

### docksal.env environment
You can pass any variable to `docksal-local.env`

#### Samples:
```
docksal_env:
  DOCKSAL_STACK: acquia
``` 
## Environment/branch specific overwrites `.andock/andock.{{ branch }}.yml`:
To overwrite configuration for a specific environment you can add an branch specific setting.

For example configure your production domain to the master environment `.andock/andock.master.yml`.
```
virtual_hosts:
  default: 
    virtual_host: "www.domain.com"
    container: web
```


!!! tip "Own template generation files?"
    To overwrite the generation templates you can define your own template files. Simple add `docksal_local_yml_path` or `docksal_local_env_path` to your `andock.yml`

