# peripheral-manager-mock
Exemplary repository for demonstrating the creation of a custom NuvlaBox Peripheral Manager

This code is purely educational. It is meant to be used as an example and foundation for your own custom NuvlaBox Peripheral Manager. 

Read more about this at [NuvlaBox Docs](https://docs.nuvla.io/nuvlabox/contributing/custom-peripheral-managers.html)

# Building this Docker image

## Simple build

Just run `docker build . -t <your_image_name>`. And the push the Docker image: `docker push <your_image_name>`.

## Multi-platform build

Make sure you have `docker buildx`. If not, have a look at: https://docs.docker.com/buildx/working-with-buildx/

```shell
# Create the build context:
docker buildx create --name multiplatformbuilder --use

# Bootstrap the context and make sure your targeted platforms are supported by it
docker buildx inspect --bootstrap

# Build and push the Docker image
# Feel free to replace the platforms below by the ones you're targeting
docker buildx build --platform linux/arm/v6,linux/arm/v7,linux/amd64,linux/arm64 -t <your_image_name> . --push
```

## Copyright

Copyright &copy; 2021, SixSq SA
