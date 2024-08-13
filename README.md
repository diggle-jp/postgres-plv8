# postgres-plv8

AWS に準じた postgreSQL - PLV8 のバージョンを作成する

## How to use

### docker run

```
docker run -e POSTGRES_HOST_AUTH_METHOD=trust -p 5432:5432 ghcr.io/diggle-jp/postgres-plv8/postgres:13.13-3.1.8
```

### docker-compose.yml

```
db:
  image: ghcr.io/diggle-jp/postgres-plv8/postgres:13.13-3.1.8
```

## How to update

1. update Dockerfile
2. make Release Tag `(postgres version)-(plv8 version)` e.g. `13.13-3.1.8`
3. add new Release to https://github.com/diggle-jp/postgres-plv8/releases

# License

This code is free to use under the terms of the MIT license.
