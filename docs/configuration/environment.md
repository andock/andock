# Environment 

<b>Andock</b> creates updates and destroy environments. Customizeable through ansible hooks.

## Hooks

Hooks can be registered in your andock.yml. 

| File name                  | Description |
|----------------------------|:------------|
| `hook_init_tasks`     | Hook fired while `andock deploy` (if the environment is new)|
| `hook_update_tasks`   | Hook fired while `andock deploy` (if the environment already exists)|
| `hook_test_tasks`     | Hook fired while `andock environment test`|
| `deploy_done_tasks`     | Hook fired after `andock deploy`|
| `deploy_failed_tasks`     | Hook fired after `andock deploy` failed|

### Init hook
The `init hook` is fired after the environment is created. if `andock deploy` is called a second time the init hook will not be fired again. You must call first `andock environment rm` to reinitizialize the environment again.  
### Update hook:
The `update hook` is fired after each `anddock deploy`
### Test hook:
The `test hook` is fired after each `andock environment test`. This hook should be used to run `behat` or other ui tests.

### Deploy done:
The `deploy done hook` is fired if the deployment was successfully. 

### Deploy failed:
The `deploy failed hook` is fired if the deployment failed. 

## Samples:
### init_tasks.yml
```
 - name: Init andock environment
   command: "fin init"
   args:
     chdir: "{{ docroot_path }}"
```
 
### update_tasks.yml
```
 - name: Composer install
   command: "fin exec composer install"
   args:
     chdir: "{{ environment_path }}"
 - name: Clear cache
   command: "fin drush cr"
   args:
     chdir: "{{ docroot_path }}"
```
