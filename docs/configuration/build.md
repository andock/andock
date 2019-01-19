# Build configuration 

Run `andock build deploy` to build the deployment artifact and push it to the artifact repository.

Run `andock build` to build the deployment artifact without pushing it to the artifact repository. This can be useful if you use any other tool (e.g. acquia blt) to manage the deployment of the artifact.
 
Run `andock build clean` to cleanup the build caches. 
 
!!! tip "Run builds on your CI or don't need builds?"
    Specify the artifact `git_artifact_repository_path` and the `target_branch_suffix` in `andock.yml` and run only `andock deploy`.

## Configuration options:

| Option                     | Description |
|----------------------------|:------------|
| `cache_build`            | Enable or disable build cache. Default is `true`.
| `fin_up_during_build`            | Run fin up during build. Default is `false`
| `target_branch_suffix`            | The suffix of the artifact branch name. Default is `no suffix`
| `git_artifact_repository_path`            | The built artifact is pushed to this repository. `Andock` generate one repository for each project.
| `remove_gitignore_during_build`            | Remove all .gitignore files before deploy to artifact repository. Default is `true`

## Path environment variables:

| Path                     | Description |
|----------------------------|:------------|
| `build_path`            | The build checkout path.

### Sample hooks:
The build tasks are configured in `.andock/hooks/build_tasks.yml`. 
```yaml
- name: Composer validate
  command: "fin rc -T composer validate --no-check-all --ansi"
  args:
    chdir: "{{ build_path }}"

- name: Composer install
  command: "fin rc -T composer install --ansi --no-dev"
  args:
    chdir: "{{ build_path }}"

```

## Advanced build configuration

### .gitignore
If you need more control which files/folders should be part of the build artifact you can set `remove_gitignore_during_build` to `false` in your `andock.yml`.
Parts between `#### BEGIN REMOVE ANDOCK ###` will be removed in any .gitignore file.
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

