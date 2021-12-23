# docker-plv8
AWSに準じたpostgreSQL - PLV8のバージョンを作成する

## How to use
### docker run
```
docker run -e POSTGRES_HOST_AUTH_METHOD=trust -p 5432:5432 ghcr.io/zakky21/docker-plv8/plv8:xx.x
```

### docker-compose.yml
```
db:
  image: ghcr.io/zakky21/docker-plv8/plv8:xx.x
```

## How to update
1. update Dockerfile
2. create Release Tag
