# Fin Hooks 

Andock is handles the creation updating and removing of environments. Each lifecycle step is configurable through an ansible hook file.

| File name                  | Description |
|----------------------------|:------------|
| `hooks/init_tasks.yml`     | Hook fired while `fin init, fin deploy` |
| `hooks/update_tasks.yml`   | Hook fired while `fin update, fin deploy`|
| `hooks/test_tasks.yml`     | Hook fired while `fin test`|

### Init hook
The `init hook` runs after the environment is created. if `fin init` or `fin deploy` is called a second time the init hook will not be fired.
### Update hook:
The `update hook` runs after each `fin update` or `fin deploy`
### Test hook:
The `test hook` runs after each `fin test`. This hook should be used to run `behat` or other ui tests.

## Samples:
### init_tasks.yml
```
 - name: Init andock environment
   command: "fin init"
   args:
     chdir: "{{ docroot_path }}"
   when: instance_exists_before == false
```
 
### update_tasks.yml
```
 - name: Composer install
   command: "fin exec composer install"
   args:
     chdir: "{{ project_path }}"
 - name: Clear cache
   command: "fin drush cr"
   args:
     chdir: "{{ docroot_path }}"
```
