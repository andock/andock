# Environments 

<b>Andock</b> creates an environment for each branch. 

Andock checks out the latest artifact from artifact repository and runs all tasks either from the init or update tasks to initialize or update the environment.

To deploy an environment run `andock deploy`.
## Hooks overview

Hooks can be registered in your `andock.yml`. 

| File name                  | Description |
|----------------------------|:------------|
| `hook_init_tasks`     | Hook fired while `andock deploy` (if the environment is new)|
| `hook_update_tasks`   | Hook fired while `andock deploy` (if the environment already exists)|
| `hook_test_tasks`     | Hook fired while `andock environment test`|
| `hook_deploy_done_tasks`     | Hook fired after `andock deploy`|
| `hook_deploy_failed_tasks`     | Hook fired after `andock deploy` failed|


## Samples:

### init_tasks.yml
```
 - name: Init Andock environment
   command: "fin andock-init"
   args:
     chdir: "{{ docroot_path }}"
```
 
### update_tasks.yml
```
 - name: Clear Drupal cache
   command: "fin drush cr"
   args:
     chdir: "{{ docroot_path }}"
```

## Path environment variables:

| Path                     | Description |
|----------------------------|:------------|
| `environment_path`            | The root directory of the environment.
| `docroot_path`            | The docroot path.
