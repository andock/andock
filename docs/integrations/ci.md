# CI configuration

## Travis (standalone).
```
sudo: required
dist: trusty
language: generic
before_install:
- curl -sS https://raw.githubusercontent.com/andock/andock/master/install-andock | sh
- . andock ssh-add "$SSH_PRIVATE_KEY"

script:
- andock build
- andock deploy

```

## Gitlab (docker).
```
stages:
  - build
  - deploy

before_script:
  - . andock ssh-add "$SSH_PRIVATE_KEY"
  - andock version

build:
  stage: build
  image: andockio/andock:latest
  script:
    - andock build
  environment:
    name: andock/$CI_COMMIT_REF_NAME
    url: http://$CI_ENVIRONMENT_SLUG.$CI_PROJECT_NAME.example.com
    on_stop: stop_environment
  only:
    - branches

deploy:
  stage: deploy
  image: andockio/andock:latest
  script:
    - andock deploy
  environment:
    name: andock/$CI_COMMIT_REF_NAME
    url: http://$CI_ENVIRONMENT_SLUG.$CI_PROJECT_NAME.example.com
    on_stop: stop_environment
  only:
    - branches

stop_environment:
  stage: deploy
  image: andockio/andock:latest
  variables:
    GIT_STRATEGY: none
  script:
    - andock fin remove
  when: manual
  environment:
    name: andock/$CI_COMMIT_REF_NAME
    action: stop

```