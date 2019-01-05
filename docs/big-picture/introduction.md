# Big picture.

<b>Andock</b> is designed having two scenarios in mind:

1. You can use Andock to host small to medium-sized Docksal projects in the cloud or on any Bare Metal Server with minimum configuration effort and without any other necessary server infrastructure. 
2. If you host your project on Acquia, platform.sh or others, you can use <b>Andock</b> for unlimited staging environments.

Your code must be managed by GIT. <b>Andock</b> will build one environment for each git branch. The configuration is driven by a small number of YAML files in your Git repository

<b>Andock</b> uses a set of ansible roles to manage the complete build and deploy life cycle of your Docksal project. Ansible offers an extensive kit, which allows you to extend the workflow according to your requirements. 

The <b>Andock cli</b> is a simple command line tool. You can use it as Docksal add-on in your project, as stand-alone for non-dockerized CIs, or as a docker image for dockerized CIs. 

You can use *Andock* with or without a CI server.

## "build &amp; deploy"
*Andock* has two main phases.

### The build phase.
After you run `andock build deploy` Andock checks out the last commit of your branch, run all build hooks to include dependencies, run tests and pushes the built artifact to the git artifact repository.

While build, you can use all Docksal tools and spin up all Docksal services to run phpunit, behat or any other test tool.

The build phase is optional. You can build your project on your CI server with other tools like acquia blt to manage your own build and specify the remote artifact repository.

For more infos [see build configuration](../configuration/build.md)

### The deploy phase.
After you run `andock environment deploy` Andock checks out the last commit from the artifact repository, generates all necessary configuration files, mounts the filesystem, generates Let's encrypt certificates and start all services.
 
For more infos [see build configuration](../configuration/environment.md)
### Getting started?
* New to <b>Andock</b>   see the [5 minutes setup](../getting-started/docksal.md)

* To get an overview about the configuration check out the 
[configure configuration](../configuration/andock.md) 


