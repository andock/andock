# Big picture.

<b>Andock</b> is designed with two scenarios in mind:

1. Host small to medium sized docksal projects in the cloud or on any bare metal server with minimal configuration effort and no need of any other server infrastructure. 
2. Host your project on Acquia, platform.sh etc and use <b>andock</b> for feature branch based review apps.

Your code must be managed by GIT. Andock will built and generate one environment for each git branch. The configuration is driven by a small number of YAML files in your Git repository

<b>Andock</b> is a set of ansible roles to manage the complete build and deploy life cycle of your docksal project. With the power of ansible you can also easily extend the workflow. 

The <b>andock cli</b> is a simple command line tool to execute the roles. You can use the command line tool as docksal addon inside your porject, as standalone for non dockerized CIs, or as a docker image for dockerized CIs. 

You can use andock with or without an CI server.

## "build &amp; deploy"
Here a short overview of the two main phases.

### The build phase.
You can optionally build your project with anodck. It also possible to build it with other tools like Acquia blt.
 
* Checks out your git repository.
* Run all task from `hooks/build.yaml`.
* Optionally `fin up` a build environment to run unit tests like you would do it .
* Push the result to an artifact repository.

[See configuration](../configuration/build.md)

### The deploy phase.
* Checks out the builded artifact git repository.
* Generates `docksal-local.yml` and `docksal-local.env` configuration files.
* Run all task from `hooks/init_tasks.yaml` or `hooks/update_tasks.yaml`.
* Starts or update an docksal environment
* Generate Let's encrypt certificates.

[See configuration](../configuration/deploy.md)
### Getting started?
If you are new to andock and want to give it a try: 
[5 minutes setup](../getting-started/docksal.md)

To get an overview about the configuration check out: 
[Configure your project](../configuration/andock.md) 



