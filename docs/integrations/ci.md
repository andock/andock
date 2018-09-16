# CI configuration

## Travis (standalone).
Add your private ssh key run: 
```
# Install Travis command line tool.
gem install travis

# Login to Travis Pro (private repositories) account.
travis login

# Add encrypted key.
travis encrypt-file YOUR_DEPLOY_PRIVATE_KEY --add
```

Copy sample travis.yml: 
```
sudo: required
dist: trusty
language: generic
env:
  ENCRYPTION_LABEL: ENCRYPTION_LABEL 
before_install:
- curl -sS https://raw.githubusercontent.com/andock/andock/master/install-andock | sh
- ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
- ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
- ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
- ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
- openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in andock_key.enc -out ~/.ssh/id_rsa -d
- SSH_PRIVATE_KEY=$(cat ~/.ssh/id_rsa)
- . andock ssh-add "$SSH_PRIVATE_KEY"

script:
- andock build
- andock deploy

```

## Gitlab (docker).
To add your private ssh key see [gitlab docs](https://docs.gitlab.com/ee/ci/ssh_keys/). 
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
    - andock fin rm
  when: manual
  environment:
    name: andock/$CI_COMMIT_REF_NAME
    action: stop

```
