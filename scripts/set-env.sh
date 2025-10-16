docker build -t lightos-builder -f docker/dockerfile .
docker run -it --rm -v $PWD:/work lightos-builder bash