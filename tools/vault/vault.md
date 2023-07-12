## Vault

Vault is a secrets management service by Hashicorp.

It allows you to store all of your secrets in one place.

Vault encrypts the secrets before saving them to an external storage.

Vault can revoke secrets and can create short-lived secrets.

Vault integrates with databases/services/etc and can dynamically create credentials for
PostgreSQL/etc

Install Vault
```shell
brew tap hashicorp/tap
brew install hashicorp/tap/vault
```

Start Vault in development mode
```shell
vault server -dev
```

`vault server -dev` will print unseal_key and root_token. 
Save them somewhere.

In a new terminal
```shell
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN={root_token}
```

Check Vault server status
```shell
vault status
```

Let's get a dynamic PostgreSQL secret
```shell
export POSTGRES_URL=127.0.0.1:5432
vault secrets enable database
```

Create database config
```shell
vault write database/config/postgresql \
     plugin_name=postgresql-database-plugin \
     connection_url="postgresql://{{username}}:{{password}}@$POSTGRES_URL/postgres?sslmode=disable" \
     allowed_roles=readonly \
     username="root" \
     password="rootpassword"
```

Make a template to create new readonly role
```shell
tee readonly.sql <<EOF
CREATE ROLE "{{name}}" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;
GRANT ro TO "{{name}}";
EOF
```

Create `ro` role in your psql 
```sql
-- TODO: make it really readonly
CREATE ROLE ro;
```

Create readonly role with the ttl of 1 minutes
```shell
vault write database/roles/readonly \
db_name=postgresql \
creation_statements=@readonly.sql \
default_ttl=1m \
max_ttl=24h
```

Get readonly credentials
```shell
vault read database/creds/readonly
```

This PostgreSQL credentials will expire after 1 minute.