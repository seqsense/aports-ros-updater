UPDATER_NAME            = aports-ros-updater
ALPINE_VERSION         ?= 3.20
ROS_DISTRO             ?= noetic
ROS_PYTHON_VERSION     ?= 3
ROS_DISTRIBUTION_TYPE  ?= ros1

IMAGE_TAG               = $(ROS_DISTRO).v$(ALPINE_VERSION)

.PHONY: build-updater
build-updater:
	docker build -t $(UPDATER_NAME):$(IMAGE_TAG) \
		--build-arg ROS_DISTRO=$(ROS_DISTRO) \
		--build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
		.

.PHONY: run
run:
	docker run --rm \
		-v ${HOME}/.netrc:/root/.netrc:ro \
		-e ROS_PYTHON_VERSION=$(ROS_PYTHON_VERSION) \
		-e ROS_DISTRIBUTION_TYPE=$(ROS_DISTRIBUTION_TYPE) \
		$(UPDATER_NAME):$(IMAGE_TAG)

.PHONY: dry-run
dry-run:
	docker run --rm \
		-v ${HOME}/.netrc:/root/.netrc:ro \
		-e ROS_PYTHON_VERSION=$(ROS_PYTHON_VERSION) \
		-e ROS_DISTRIBUTION_TYPE=$(ROS_DISTRIBUTION_TYPE) \
		$(UPDATER_NAME):$(IMAGE_TAG) -d
