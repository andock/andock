# Let's Encrypt configuration 

Enable Let's Encrypt in your andock.yml

```yaml
letsencrypt_enable: true
```

Andock creates a certificate for each vitual_host and stores them into .docksal/certs. 


## Configuration options overview:

| Option                     | Description |
|----------------------------|:------------|
| `letsencrypt_enable`            | Enable or disable Let's Encrypt. Default is `false`.
| `letsencrypt_directory`            | Switch between lets encrypt staging and production. For staging use `letsencrypt_directory_staging` for production: `letsencrypt_directory_production`.   
| `letsencrypt_challenge_type`            | The Let's encrypt challange type. Default is `http-01`
| `letsencrypt_domains`            | A ansible dictonary for all Let's Encrypt domains for one environment. Default is `virtual_hosts`.

For more details see [the ansible docs](https://docs.ansible.com/ansible/2.5/modules/letsencrypt_module.html).