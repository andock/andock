# Notifications

If you want to get notified if something goes wrong with your build or your deployment simple use the ansible tool of your choice to get notified.

Register your hook_build_failed or hook_deploy_failed in your `andock.yml`. 

## Slack sample:

[Read the ansible documentation for more infos](https://docs.ansible.com/ansible/2.6/modules/slack_module.html)
### andock.yml:
Register your hook. 
```
# Build
hook_build_failed_tasks: "{{project_path}}/.andock/hooks/build_failed_tasks.yml"
hook_build_done_tasks: "{{project_path}}/.andock/hooks/build_done_tasks.yml"

# Deploy
hook_deploy_failed_tasks: "{{project_path}}/.andock/hooks/deploy_failed_tasks.yml"
hook_deploy_done_tasks: "{{project_path}}/.andock/hooks/deploy_done_tasks.yml"

```
### build_failed_tasks.yml:
```
- name: Build failed
  slack:
    token: thetoken/generatedby/slack
    msg: 'Build {{ project_name }} {{ branch }} failed'
    channel: '#ansible'
    username: 'Ansible on {{ inventory_hostname }}'
    icon_url: http://www.example.com/some-image-file.png
    link_names: 0
    parse: 'none'
```

## Mail sample:
[Read the ansible documentation for more infos](https://docs.ansible.com/ansible/2.6/modules/mail_module.html)