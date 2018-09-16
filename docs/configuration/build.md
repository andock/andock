# Build configuration 

Run `andock build` to start the build. 
 
!!! tip "Run your own builds?"
    If you build the project on your CI? Add the repository including the build artifacts as `git_artifact_repository_path` to the `andock.yml` and just run `andock deploy`.

## Configuration options:

| Option                     | Description |
|----------------------------|:------------|
| `cache_build`            | Enable or disable build cache. Default is `true`.
| `fin_up_while_build`            | Run fin up while build. Default is `false`
| `target_branch_suffix`            | The suffix of the artifact branch name. Default is `no suffix`
| `git_artifact_repository_path`            | The builded artifact is pushed to this repository. Andock generate one repository for each project.   
 

## Path environment variables:

| Path                     | Description |
|----------------------------|:------------|
| `build_path`            | The build checkout path.

## Hooks

Hooks can be registered in your andock.yml. 

| File name                  | Description |
|----------------------------|:------------|
| `build_tasks`     | Hook fired while `andock build` |
| `build_done_tasks`     | Hook fired after `andock build`|
| `build_failed_tasks`     | Hook fired after `andock build` failed|

### Registration sample:
andock.yaml
```
hook_build_tasks: "{{project_path}}/.andock/hooks/build_tasks.yml"
```

### Sample hooks:
The build tasks are configured in `.andock/hooks/build_tasks.yml`. 
```yaml
- name: Composer
  command: "composer install"
  args:
    chdir: "{{ buid_path }}"
- name: npm install
  command: "npm install"
  args:
    chdir: "{{ buid_path }}/docroot/themes/custom/theme"
- name: Compile scss
  command: "npm run compile"
  args:
    chdir: "{{ buid_path }}/docroot/themes/custom/theme"
```

## .gitignore
To commit builded artifacts the folders must be removed from .gitignore.
To easily manage this you can use ansible file blocks.
```
#### BEGIN REMOVE ANDOCK ###
Folders  
#### END REMOVE ANDOCK ###
```
### Sample:
```
#### BEGIN REMOVE ANDOCK ###
docroot/core
docroot/modules/contrib
docroot/themes/contrib
docroot/profiles/contrib
vendor
#### END REMOVE ANDOCK ###
```
## 
    
