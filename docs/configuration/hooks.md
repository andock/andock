# Hooks  
With hooks you can define what happens while build or deploy. Hooks are [ansible tasks](https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html#tasks-list) which are exectued by Andock while the build or deploy phase and after the build and deploy phase.

## Hooks overview:

### Build:
| File name                  | Description |
|----------------------------|:------------|
| `hook_build_tasks`     | Hook fired while `andock build` |
| `hook_build_done_tasks`     | Hook fired after `andock build`|
| `hook_build_failed_tasks`     | Hook fired after `andock build` failed|

### Deploy:
| File name                  | Description |
|----------------------------|:------------|
| `hook_init_tasks`     | Hook fired while `andock deploy` (if the environment is new)|
| `hook_update_tasks`   | Hook fired while `andock deploy` (if the environment already exists)|
| `hook_test_tasks`     | Hook fired while `andock environment test`|
| `hook_deploy_done_tasks`     | Hook fired after `andock deploy`|
| `hook_deploy_failed_tasks`     | Hook fired after `andock deploy` failed|

### Registration:
Hooks must be registered in `andock.yml`. Here a full list of all hook registrations.

Build hooks:
```
# Build hooks
hook_build_tasks: "{{project_path}}/.andock/hooks/build_tasks.yml"
hook_build_done_tasks: "{{project_path}}/.andock/hooks/build_done_tasks.yml"
hook_build_failed_tasks: "{{project_path}}/.andock/hooks/build_failed_tasks.yml"
```
Environment hooks:
```
hook_init_tasks: "{{project_path}}/.andock/hooks/init_tasks.yml"
hook_update_tasks: "{{project_path}}/.andock/hooks/update_tasks.yml"
hook_test_tasks: "{{project_path}}/.andock/hooks/test_tasks.yml"
hook_deploy_done_tasks: "{{project_path}}/.andock/hooks/deploy_done_tasks.yml"
hook_deploy_failed_tasks: "{{project_path}}/.andock/hooks/hook_deploy_failed_tasks.yml"
```

