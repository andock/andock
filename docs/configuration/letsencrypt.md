# Let's Encrypt configuration 

Enable Let's Encrypt in your andock.yml

```yaml
letsencrypt_enable: true
```

Andock creates an certificate for each vitual_host and stores them into .docksal/certs. Docksal loads all certificates in this folder.

## Advanced domain configuration
If you need a differnt domain for your certificate than the virtual host (if you use an varnish for example) you can configure domains seperatly. 

```yaml
letsencrypt_domains:
  default: "www.{{ branch }}.example.com"
```

## Configuration options overview:

| Option                     | Description |
|----------------------------|:------------|
| `letsencrypt_enable`            | Enable or disable Let's Encrypt. Default is `false`.
| `letsencrypt_acme_directory`            | Switch between lets encrypt staging and production. For staging use `letsencrypt_acme_directory_staging` for production: `letsencrypt_acme_directory_production`.   
| `letsencrypt_challenge_type`            | The Let's encrypt challange type. Default is `http-01`
| `letsencrypt_domains`            | A ansible dictonary for all Let's Encrypt domains for one environment. Default is `virtual_hosts`.

For more details see [the ansible docs](https://docs.ansible.com/ansible/2.5/modules/letsencrypt_module.html).