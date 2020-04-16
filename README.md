# peripheral-manager-mock
Exemplary repository for demonstrating the creation of a custom NuvlaBox Peripheral Manager

This code is purely educational. It is meant to be used as an example and foundation for your own custom NuvlaBox Peripheral Manager. 

Read more about this at [NuvlaBox Docs](https://docs.nuvla.io/nuvlabox/contributing/custom-peripheral-managers.html)

# Building this Docker image

## Simple build

Just run `docker build . -t <your_image_name>`.

## Multi-platform build

Make sure you have `docker buildx`. If not, have a look at: https://docs.docker.com/buildx/working-with-buildx/

Create the build context:
```shell
docker buildx create --name multiplatformbuilder --use

docker buildx inspect --bootstrap

# Feel free to replace the platforms below by the ones you're targeting
docker buildx build --platform linux/arm/v6,linux/arm/v7,linux/amd64,linux/arm64 -t <your_image_name> . --push
```

