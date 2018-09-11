# Big picture.

<b>Andock</b> is designed to host your docksal project in the cloud or on any bare metal server with minimal configuration effort. 

You can use it for production for small to medium projects as well as for feature branch review environments.

Your code must be managed by GIT. Andock will built and generate one environment for each git branch. The configuration is driven by a small number of YAML files in your Git repository

<b>Andock</b> is a set of ansible roles to manage the complete build and deploy life cycle of your docksal project. With the power of ansible you can also easily extend the workflow.

The <b>andock cli</b> is a simple command line tool to execute the roles. You can use the command line tool as docksal addon inside your porject, as standalone for non dockerized CIs, or as a docker image for dockerized CIs. 

You can use andock with or without an CI server.

## "build &amp; deploy"
Here a short overview of the two main phases.

### The build phase.
* Checks out your git repository 
* Run all task from `hooks/build.yaml`.
* Optionally `fin up` a build environment to run unit tests.
* Store the build artifact.

[See configuration](../configuration/build.md)

### The deploy phase.
* Checks out the builded artifact 
* Generates `docksal-local.yml` and `docksal-local.env` configuration files.
* Run all task from `hooks/init_tasks.yaml` or `hooks/update_tasks.yaml`.
* Starts or update an docksal environment
* Generate Let's encrypt certificates.

### Getting started?
If you are new to andock and want to give it a try: 
[5 minutes setup](../getting-started/docksal.md)

To get an overview about the configuration check out: 
[Configure your project](../configuration/andock.md) 



[See configuration](../configuration/fin.md)


