# VeRIKA architecture diagrams

## Archived!

⚠️ The content here is outdated. Structurizr diagrams are now part of the [ris-backend-service repo](https://github.com/digitalservicebund/ris-backend-service/tree/main/doc/structurizr)

## Original general info

Diagrams as code using [Structurizr](https://structurizr.com)

## Prerequisites

Docker

```
$ brew install docker --cask
```

## Start Structurizr Lite

See https://structurizr.com/help/lite

```
$ cd ris
$ docker pull structurizr/lite
$ docker run -it --rm -p 8080:8080 -v "$(pwd):/usr/local/structurizr" structurizr/lite
```

Open workspace in browser at http://localhost:8080
