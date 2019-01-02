# Big picture.

<b>Andock</b> is designed having two scenarios in mind:

1. You can use andock to host small to medium-sized docksal projects in the cloud or on any Bare Metal Server with minimum configuration effort and without any other necessary server infrastructure. 
2. If you host your project on Acquia, platform.sh or others, you can use <b>Andock</b> for unlimited staging environments.

Your code must be managed by GIT. <b>Andock</b> will build one environment for each git branch. The configuration is driven by a small number of YAML files in your Git repository

<b>Andock</b> uses a set of ansible roles to manage the complete build and deploy life cycle of your docksal project. Ansible offers an extensive kit, which allows you to extend the workflow according to your requirements. 

The <b>Andock cli</b> is a simple command line tool. You can use it as docksal add-on in your project, as stand-alone for non-dockerized CIs, or as a docker image for dockerized CIs. 

You can use andock with or without a CI server.

## "build &amp; deploy"
Here a short overview of the two main phases.

### The build phase.
You can build your project with <b>Andock</b>. It is also possible to build it with other tools like Acquia blt.
 
[DIAGRAM]
[See configuration](../configuration/build.md)

### The deploy phase.
[DIAGRAM]
 
[See configuration](../configuration/environment.md)
### Getting started?
If you are new to <b>Andock</b> and want to give it a try: 
[5 minutes setup](../getting-started/docksal.md)

To get an overview about the configuration check out: 
[Configure your project](../configuration/andock.md) 



