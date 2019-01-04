# Htaccess redirects
Redirects should be done in the .htaccess file.

## Sample https://www.example.com configuration:
Redirects all <b>http urls</b> to <b>https://www.example.com</b>:
```

  # Rewrite http(s)://example.com to https://www.example.com
  RewriteCond "%{HTTP_HOST}" "!^www\." [NC]
  RewriteCond "%{HTTP_HOST}" "!^$"
  RewriteCond %{ENV:ANDOCK} 1
  RewriteCond %{REQUEST_URI} "!/.well-known/acme-challenge/"
  RewriteRule ^ https://www.%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

  # Rewrite http://www.example.com to https://www.example.com
  RewriteCond %{HTTPS} off
  RewriteCond %{HTTP:X-Forwarded-Proto} !https
  RewriteCond %{ENV:ANDOCK} 1
  RewriteCond %{REQUEST_URI} "!/.well-known/acme-challenge/"
  RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

  # Rewrite https://example.com to https://www.example.com
  RewriteCond %{HTTPS} on
  RewriteCond %{HTTP:X-Forwarded-Proto} https
  RewriteCond "%{HTTP_HOST}" "!^www\." [NC]
  RewriteCond %{ENV:ANDOCK} 1
  RewriteCond %{REQUEST_URI} "!/.well-known/acme-challenge/"
  RewriteRule ^ https://www.%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

