# Big picture.

andock is designed to host your docksal project in the cloud. You can use andock for feature branch based development environment BUT it is also designed to use it in production for small to medium sized projects. You are free to choose your cloud solution.

Your code must be managed by GIT. andock will generate one environment for each branch. The configuration is driven by a small number of YAML files in your Git repository

andock is a set of ansible roles to manage the complete build and deploy life cycle of your docksal project. With the power of ansible you can also easily extend the workflow.

The <b>andock cli</b> is a simple command line tool to execute the roles.<br><br>
It builds your project and deploy the artifact to a artifact repository. You can spin up an docksal environment or run fin rc to run composer or npm while build. After a successful build andock will start or update an environment.

To use andock you must install docksal on your server. This can easily done with andock server:install

If you are new to andock and want to give it a try: 
[5 minutes setup](../getting-started/docksal.md)

If you want to get an overview about the configuration structure see:
[5 minutes setup](configuration-structure.md) 
 

## "build &amp; fin"
Here a short overview of the two main phases.
### The build phase.
* Checks out your git repository 
* Run all task from hooks/build.yaml.
* Optionally you can `fin up` your environment to run unit tests.
* If everything works fine the artifact is pushed to a local artifact repository.

[See configuration](../configuration/build.md)
### Fin lifecycle.
With andock fin you can create/start/stop/update/remove docksal environment  
* Checks out the builded artifact 
* Generates docksal-local configuration files.
* create/start/stop/update/remove docksal environment

[See configuration](../configuration/fin.md)

