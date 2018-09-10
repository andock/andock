# Big picture.

andock is designed to host your docksal project in the cloud or on any bare metal server. You can use andock for feature branch based development environment BUT it is also designed to use it in production for small to medium sized projects. You are free to choose your cloud solution.

Your code must be managed by GIT. andock will generate one environment for each branch. The configuration is driven by a small number of YAML files in your Git repository

andock is a set of ansible roles to manage the complete build and deploy life cycle of your docksal project. With the power of ansible you can also easily extend the workflow.

The <b>andock cli</b> is a simple command line tool to execute the roles.<br><br>
It builds your project and deploy the artifact to a artifact repository. You can spin up an docksal environment or run fin rc to run composer or npm while build. After a successful build andock will start or update an environment.

To use andock you must install docksal on your server. This can easily done with andock server:install

If you are new to andock and want to give it a try: 
[5 minutes setup](../getting-started/docksal.md)

Configure your project:
[Configure your project](../configuration/andock.md) 
 

## "build &amp; deploy"
Here a short overview of the two main phases.
### The build phase.
* Checks out your git repository 
* Run all task from hooks/build.yaml.
* Optionally you can `fin up` your environment to run unit tests.
* If everything works fine the artifact is pushed to a local artifact repository.

[See configuration](../configuration/build.md)
### The deploy phase.
* Checks out the builded artifact 
* Starts or update an andock environment
## Andock fin lifecycle
With andock fin you can create/start/stop/update/remove docksal environment.  
* Checks out the builded artifact 
* Generates `docksal-local.yml` and `docksal-local.env` configuration files.
* Create docksal environment
* Start docksal environment
* Generate Let's encrypt certificates.
* Update docksal environment
* Stop docksal environment
* Remove docksal environment

[See configuration](../configuration/fin.md)

