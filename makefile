.PHONY: run build shell clean

IMAGE_NAME := lightos-builder
DOCKERFILE := docker/dockerfile
WORKDIR := $(shell pwd)

build:
	docker build -t $(IMAGE_NAME) -f $(DOCKERFILE) .

run: build
	docker run -it --rm -v $(WORKDIR):/work $(IMAGE_NAME) bash

shell:
	docker run -it --rm -v $(WORKDIR):/work $(IMAGE_NAME) bash

clean:
	rm -rf $(WORKDIR)/build/out \
	       $(WORKDIR)/build/linux \
	       $(WORKDIR)/rootfs/init \
	       $(WORKDIR)/rootfs/usr/bin/svc-echo
