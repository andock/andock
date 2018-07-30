# Concept overview.
andock is a set of ansible roles to manage the complete build and deploy life cycle and a command line tool to manage these ansible roles.

## Pipeline steps:
* build (unit tests, deploy to deployment branch)
* Environment creation/updates
* QA tests 
* Environment removal

## Ansible roles
* server
* build
* fin

### Role: server
Manages docksal installations and updates. 

### Role: build
Build project and deploy the artifact to a target repository. Right now only git repositories are supported but in future other deploy strategy should supported.
This runs typically on CI server. [See configuration](build.md)

### Role: fin
Checks out the deployed artifact and run fin up. [See configuration](fin.md)