[![Latest Release](https://img.shields.io/github/release/andock/build.svg?style=flat-square)](https://github.com/andock/andock/releases/latest) [![Build Status](https://img.shields.io/travis/andock/build.svg?style=flat-square)](https://travis-ci.org/andock/build)

andock-build 
=========

**andock-build** is a Ansible role which checks out the last commit of your branch, run all build hooks to include dependencies, run tests and pushes the built artifact to the git artifact repository.
  

Requirements
------------

In order to build your apps with Andock, you will need:

* Ansible in your deploy machine
* build tools like composer or something else
* git on both machines


Role Variables
--------------

```yaml
vars:
  git_source_repository_path: git@github.com:andock/drupal-8-demo.git # The source repository 
  git_target_repository_path: git@github.com:andock/drupal-8-demo-build.git # The target repository. Can be the same repository as the source repository 
  build_path: ~/ansible # The path where the build happens
  branch: "master" # The source branch. The target branch would be master-build
  hook_build_tasks: "hooks/build_tasks.yml" # The path to your build_tasks hook file
```

Installation
------------

Andock is an Ansible role distributed globally using [Ansible Galaxy](https://galaxy.ansible.com/). In order to install Andock role you can use the following command.

```
$ ansible-galaxy install andock.build
```

Update
------

If you want to update the role, you need to pass **--force** parameter when installing. Please, check the following command:

```
$ ansible-galaxy install --force andock.build
```

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - name: Deploy repository to build repository
      hosts: localhost
      
      roles:
        - role: build
          git_source_repository_path: git@github.com:andock/drupal-8-demo.git
          build_path: ~/ansible
          branch: "master"
          hook_build_tasks: "hooks/build_tasks.yml"


Handling .gitignore 
----------------

You can mark parts in your .gitignore files with "BEGIN REMOVE ANDOCK" --- END REMOVE ANDOCK-CI.
andock will remove that blocks before it will be commited to target repository
 

        #Sample .gitignore file for a drupal 8 composer project
        .idea
        
        #### BEGIN REMOVE ANDOCK-CI ###
        docroot/core
        docroot/modules/contrib
        docroot/themes/contrib
        docroot/profiles/contrib
        vendor
        #### END REMOVE ANDOCK-CI ###

build hooks under .ansible/hooks/build.yml

    - name: composer install
      command: fin rc -T composer install
      args:
        chdir: "{{ build_path }}"



License
-------

GPL

Author Information
------------------

Christian Wiedemann (christian.wiedemann@key-tec.de)
