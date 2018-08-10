# Build configuration 
The build steps are configured in `.andock/hooks/build_tasks.yml`.
Run `andock build` to start the build.

### Sample build_tasks.yml
```yaml
- name: Composer
  command: "composer install"
  args:
    chdir: "{{ checkout_path }}"
- name: npm install
  command: "npm install"
  args:
    chdir: "{{ checkout_path }}/docroot/themes/custom/theme"
- name: Compile scss
  command: "npm run compile"
  args:
    chdir: "{{ checkout_path }}/docroot/themes/custom/theme"
```
### .gitignore
To commit builded artifacts the folders must be removed from .gitignore.
To easily manage this you can use ansible file blocks.
```
#### BEGIN REMOVE ANDOCK ###
Folders  
#### END REMOVE ANDOCK ###
```
#### Sample:
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

!!! tip "No build needed?"
    Build the project on your own CI or there is no need to build the project? You can define your git repository as artifact repository. Add your git repository to `git_artifact_repository_path`. 