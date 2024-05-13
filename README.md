# docker-plv8

AWS に準じた postgreSQL - PLV8 のバージョンを作成する

## How to use

### docker run

```
docker run -e POSTGRES_HOST_AUTH_METHOD=trust -p 5432:5432 ghcr.io/diggle-jp/docker-plv8/plv8:xx.x
```

### docker-compose.yml

```
db:
  image: ghcr.io/diggle-jp/docker-plv8/plv8:xx.x
```

## How to update

1. update Dockerfile
2. create Release Tag

# License

This code is free to use under the terms of the MIT license.
