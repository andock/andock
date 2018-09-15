# Build configuration 

Run `andock build` to start the build. 
 
!!! tip "Run your own builds?"
    If you build the project on your CI? Add the repository including the build artifacts as `git_artifact_repository_path` to the `andock.yml` and just run `andock deploy`.

## Configuration options overview:

| Option                     | Description |
|----------------------------|:------------|
| `cache_build`            | Enable or disable build cache. Default is `true`.
| `fin_up_while_build`            | Run fin up while build. Default is `false`
| `target_branch_suffix`            | The suffix of the artifact branch name. Default is `no suffix`
| `git_artifact_repository_path`            | The builded artifact is pushed to this repository. Andock generate one repository for each project.   
 

## build_tasks.yml
The build tasks are configured in `.andock/hooks/build_tasks.yml`.
### Sample: 
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
### Path options overview:

| Path                     | Description |
|----------------------------|:------------|
| `build_path`            | The build checkout path.

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
    
