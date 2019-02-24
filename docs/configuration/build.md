# Build 

While `build` Andock checks out the last commit of your branch, run all build hooks to include dependencies, run tests and pushes the built artifact to the git artifact repository.

During building, you have full access to all Docksal containers to run PHPUnit, Behat etc. without any other configuration effort or CI server setup. 
Add the same fin commands to the build/tests hooks as local.

## Don't need builds?
If your project doesn't need a build, you can set `git_artifact_repository_path` to your working git repository in `andock.yml` and run `andock deploy`.   

## Build on your CI server?
If you run the build on your CI server with any other build tool like Acquia BLT you need to push the built artifact to an artifact git repository.
Set this repository as `git_artifact_repository_path` in `andock.yml`. If your artifact branch has a different suffix as the source branch set the suffix `target_branch_suffix` in `andock.yml`.

## Configuration options

| Option                     | Description |
|----------------------------|:------------|
| `cache_build`            | Enable or disable build cache. Default is `true`.
| `fin_up_during_build`            | Run fin up during build. Default is `false`
| `target_branch_suffix`            | The suffix of the artifact branch name. Default is `no suffix`
| `git_artifact_repository_path`            | The built artifact is pushed to this repository. `Andock` generate one repository for each project.
| `remove_gitignore_during_build`            | Remove all .gitignore files before deploy to artifact repository. Default is `true`

## Path environment variables

| Path                     | Description |
|----------------------------|:------------|
| `build_path`            | The build checkout path.

### Sample hooks
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

