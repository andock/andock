# Andock - A poor man's PasS

__Andock__ is designed having two scenarios in mind:

1. You can use Andock to host small to medium-sized Docksal projects in the cloud or on any Bare Metal Server with minimum configuration effort and without any other necessary server infrastructure or know how. 
2. If you host your project on Acquia, platform.sh or others, you can use __Andock__ for unlimited staging environments.

Your code must be managed by GIT. Andock will build one Docksal environment for each git branch. The configuration is driven by a small number of YAML files in your Git repository.

__Andock__ uses a set of Ansible roles to manage the complete build and deploy life cycle of your Docksal project. Ansible offers an extensive kit, which allows you to extend the workflow according to your requirements. 

The Andock CLI is a simple command line tool. You can use it as Docksal add-on in your project, as stand-alone for non-dockerized CIs, or as a docker image for dockerized CIs. 

You can use Andock with or without a CI server.


It is the perfect tool if you are already developing with Docksal and want to deploy the project quickly. Andock is __not__ the tool if you need any cluster features. 

## "build &amp; deploy flow"
__Andock__ has two main phases.

### The build phase.
After you run `andock build push` Andock checks out the last commit of your branch, run all build hooks to include dependencies, run tests and pushes the built artifact to the git artifact repository. It does not generate an docker image.

While build, you can use all Docksal tools and spin up Docksal services to run phpunit, behat or any other test tool.

The build phase is optional. You can build your project on your CI server with other tools like Acquia blt to manage your build. Andock needs an git branch with all dependencies included.

For more infos [see build configuration](../configuration/build.md)

### The deploy phase.
After you run `andock environment deploy` Andock checks out the last commit from the artifact repository, generates all necessary configuration files, mounts the filesystem, generates Let's encrypt certificates and start all services.
 
For more infos [see environment configuration](../configuration/environment.md)
### Getting started?
* New to __Andock__ see the [5 minutes setup](../getting-started/docksal.md)

* Check out the [configuration overview](../configuration/andock.md) 


