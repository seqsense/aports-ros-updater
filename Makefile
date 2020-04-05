UPDATER_NAME            = aports-ros-updater
ALPINE_VERSION         ?= 3.7
ROS_DISTRO             ?= kinetic
ROS_PYTHON_VERSION     ?= 2

.PHONY: build-updater
build-updater:
	docker build -t $(UPDATER_NAME):$(ALPINE_VERSION) \
		--build-arg ROS_DISTRO=$(ROS_DISTRO) \
		--build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
		.

.PHONY: run
run: $(ROS_DISTRO)

.PHONY: dry-run
dry-run: $(ROS_DISTRO)-dry

.PHONY: $(ROS_DISTRO)
$(ROS_DISTRO):
	docker run --rm -it \
		-v ${HOME}/.netrc:/root/.netrc:ro \
		-e ROS_PYTHON_VERSION=$(ROS_PYTHON_VERSION) \
		$(UPDATER_NAME):$(ALPINE_VERSION)

.PHONY: $(ROS_DISTRO)-dry
$(ROS_DISTRO)-dry:
	docker run --rm -it \
		-v ${HOME}/.netrc:/root/.netrc:ro \
		-e ROS_PYTHON_VERSION=$(ROS_PYTHON_VERSION) \
		$(UPDATER_NAME):$(ALPINE_VERSION) -d
