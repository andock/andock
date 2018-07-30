# Build your project.  
The build process is configured through the 

### Sample build_tasks.yml
```yaml
- name: Init andock environment
  command: "composer install"
  args:
    chdir: "{{ checkout_path }}"
```
