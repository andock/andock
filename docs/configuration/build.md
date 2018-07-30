# Build configuration 
The build steps are configured in 
* `.andock/hooks/build_tasks.yml`

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