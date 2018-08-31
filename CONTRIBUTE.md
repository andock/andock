# Contributing to andock

Thanks for your interest in contributing to andock!

There are many ways you can help the project:

- [Report issues](#report-issues)
- [Contribute code](#contribute-code)



## Report issues

First search the [issue queue](https://github.com/docksal/docksal/issues). 
Others may have experienced the same or a similar issue and have already found a solution or a workaround.

File a new issue if your problem looks to be brand new.

When reporting a functionality related issue, please provide diagnostics information from `fin sysinfo`.
We aim to provide cross-platform support and need to know what's under the hood in your particular case.

Listing detailed steps to reproduce an issue will also help us understand the problem better and fix it faster.   


## Contribute code

We are sticking with [GitHub Flow](https://guides.github.com/introduction/flow/) as our git workflow.

- `develop` - development branch, all PRs should be submitted against it
- `master` - main stable branch, matches the latest release at all times
- `feature/feature-name` - isolated/experimental feature development happens here

To contribute to the project:

- Fork the repo
- Create a feature branch (optional)
- Commit code with meaningful commit messages
- Create a pull request against `develop`
- Once approved the PR will be merged

Each PR goes through automated tests on [Travis CI](https://travis-ci.org/andock/andock/pull_requests).
If your PR does not pass the tests, you either have to fix the code or fix the test.


Run tests on your local environment:

Following local test types are available:

- `lxd` The favorite test type for ubuntu users.
- `vagrant` Good old vagrant.
- `digitalocean` Run tests against an digital ocean droplet.

## Run tests

To run automated tests on your local maschine install either [lxd](https://tutorials.ubuntu.com/tutorial/tutorial-setting-up-lxd-1604#0) or [vagrant](https://www.vagrantup.com/docs/installation/) and run: 
```
cd tests
./init-local "lxd|vagrant|digitalocean"
```

