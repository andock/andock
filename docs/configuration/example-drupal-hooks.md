# Sample ansible hooks for drupal 8 

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
- name: Udpate drupal
  command: "fin drush updb -y"
  args:
    chdir: "{{ docroot_path }}"
- name: Import configuration
  command: "fin drush cim -y"
  args:
    chdir: "{{ docroot_path }}"
```
