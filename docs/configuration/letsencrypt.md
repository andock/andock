# Let's Encrypt configuration 

To enable Let's Encrypt enable it in your andock.yml

```yaml
letsencrypt_enable: true
```

## Configuration options:

| Option                     | Description |
|----------------------------|:------------|
| `letsencrypt_acme_directory`            | Switch between lets encrypt staging and production. For staging use `letsencrypt_acme_directory_staging` for production: `letsencrypt_acme_directory_production`.   
| `letsencrypt_challenge_type`            | The Let's encrypt challange type. Default is `http-01`


For more details see [the ansible docs](https://docs.ansible.com/ansible/2.5/modules/letsencrypt_module.html).