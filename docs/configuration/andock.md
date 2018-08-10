# Configuration  
The following configuration files are added to the project by running `fin acp generate:config`

Andock generates `docksal-local.env` and `docksal-local.yml` files based on ansible templates and configuration parameters.

Here is a short overview of the used configuration files:

| File name                  | Description |
|----------------------------|:------------|
| `andock.yml`            | Main configuration file.
| `andock.${branch}.yml`            | Branch specific configuration file. (optional)
| `hooks/build_tasks.yml`    | Build hook fired while `fin acp build`. |
| `hooks/init_tasks.yml`     | Build hook fired while `fin acp fin init` |
| `hooks/update_tasks.yml`   | Build hook fired while `fin acp fin update`|
| `hooks/test_tasks.yml`     | Build hook fired while `fin acp fin test`|

## The andock configuration file `.andock/andock.yml`:

#### Base configuration:
 * ` project_name: ` The name of this project, which must be unique within an andock server.
 * ` virtual_hosts:` The virtual host configuration pattern.
 * ` git_repository_path:` The git checkout repository.
virtual_hosts:
     default: "www.domain.com"
#### Mounts:
Mounts describe writeable persistent volumnes in the docker container.
Mounts are linked via volumnes: into the docker container.
``` 
mounts:
  - { name: 'files', src: 'files', path: 'docroot/files' }
```
* `name: ` The unique name of the mount.
* `src: ` The src folder name of the mount.
* `path: ` The folder path under /var/www inside the docker container. 

#### docksal.env environment
You can pass any variable to docksal-local.env

#### Sample:
```
docksal_env:
  DOCKSAL_STACK: acquia
``` 
### Environment/branch specific overwrites `.andock/andock.{{ branch }}.yml`:
To overwrite configuration for a specific environment you can add an branch specific setting.

For example configure your production domain to the master environment `.andock/andock.master.yml`.
```
virtual_hosts:
  default: "www.domain.com"
```

## Own template generation files.
> To overwrite the generation templates you can define your own template files.
Simple add `docksal_local_yml_path` or `docksal_local_env_path` to your `andock.yml`
