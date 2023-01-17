# Easy to use Hashicorp vault with auto-unseal feature

> Wrapper of [official](https://hub.docker.com/_/vault) vault docker container with unlock and auto-init capabilities for single node.

## Why ?

Just looking for something quick to have a vault on my on-premise lab and dev labs that support easy autounseal feature.

Do not use in production or environment with `real` security needs. If you need auto-unseal in these cases, you can take a look to:

- https://developer.hashicorp.com/vault/tutorials/auto-unseal

## Build

You need to have docker or similar (podman, etc.) in your machine, then:

```shell

git clone https://github.com/0ghny/docker-vault-auto-unseal
cd docker-vault-auto-unseal
docker build --name vault-as .
... this will build this container in your local machine ...
```

## Run

Once you have this image built in your machine, you can use it

- Docker command: `docker run --rm --cap-add=IPC_LOCK -p 8200:8200 -v ``pwd``/example/vault.json:/vault/config/vault.json -d vault-as`
- You can use the example/docker-compose file in this repo

### Access to UI or to Vault (Get your token)

You have two ways of access to your token (or root keys)

* if you have mounted `/vault/unlocker` folder, you will findo them in file `/vault/unlocker/keys`
* from docker logs output when you create container look for text `(VAULT UNLOCKER) [INFO]  All keys generated, your token is: <your token here>`

### Configuration

This image has the same configurations: environment variables, volumes, ports, etc. as the [official image](https://hub.docker.com/_/vault).

BUT, also it adds some extra stuff for the unlocker feature

Volumes:

* /vault/config/vault.json: Configuration file that this image will use. It's mandatory.
* /vault/logs: will contains logs, my wrapper logs are stored in `/vault/logs/vault_operator.log`.
* /vault/file: will contains the filesystem files if fs store is being used.
* /vault/unlocker: folder that will contains files created by my unlocker, by default it uses a file called `keys` where the 5 init keys and root token are stored. First 5 lines are the (position ordered) keys, and last line (6) is the root token generated when vault was initialised. The file has to be here, in order to be able to unseal the vault automatically.

