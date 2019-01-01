# Hooks  
With hooks you can adjust the build and the deploy process. Hooks are [ansible tasks](https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html#tasks-list) which are exectued by andock while the build or deploy phase and after the build and deploy phase.
Hooks must be registered in andock.yml. 

## Hooks overview:

### Build:
| File name                  | Description |
|----------------------------|:------------|
| `build_tasks`     | Hook fired while `andock build` |
| `build_done_tasks`     | Hook fired after `andock build`|
| `build_failed_tasks`     | Hook fired after `andock build` failed|

### Deploy:
| File name                  | Description |
|----------------------------|:------------|
| `hook_init_tasks`     | Hook fired while `andock deploy` (if the environment is new)|
| `hook_update_tasks`   | Hook fired while `andock deploy` (if the environment already exists)|
| `hook_test_tasks`     | Hook fired while `andock environment test`|
| `hook_deploy_done_tasks`     | Hook fired after `andock deploy`|
| `hook_deploy_failed_tasks`     | Hook fired after `andock deploy` failed|

### Registration:
andock.yaml
```
hook_build_tasks: "{{project_path}}/.andock/hooks/build_tasks.yml"
```

