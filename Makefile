UPDATER_NAME            = aports-ros-updater
ALPINE_VERSION         ?= 3.11
ROS_DISTRO             ?= noetic
ROS_PYTHON_VERSION     ?= 3
ROS_DISTRIBUTION_TYPE  ?= ros1

DISTRO_DIR              = $(ROS_DISTRO).v$(ALPINE_VERSION)

.PHONY: build-updater
build-updater:
	docker build -t $(UPDATER_NAME):$(DISTRO_DIR) \
		--build-arg ROS_DISTRO=$(ROS_DISTRO) \
		--build-arg ALPINE_VERSION=$(ALPINE_VERSION) \
		.

.PHONY: run
run: $(DISTRO_DIR)

.PHONY: dry-run
dry-run: $(DISTRO_DIR)-dry

.PHONY: $(DISTRO_DIR)
$(DISTRO_DIR):
	docker run --rm \
		-v ${HOME}/.netrc:/root/.netrc:ro \
		-e ROS_PYTHON_VERSION=$(ROS_PYTHON_VERSION) \
		-e ROS_DISTRIBUTION_TYPE=$(ROS_DISTRIBUTION_TYPE) \
		$(UPDATER_NAME):$(DISTRO_DIR) $(DISTRO_DIR)

.PHONY: $(DISTRO_DIR)-dry
$(DISTRO_DIR)-dry:
	docker run --rm \
		-v ${HOME}/.netrc:/root/.netrc:ro \
		-e ROS_PYTHON_VERSION=$(ROS_PYTHON_VERSION) \
		-e ROS_DISTRIBUTION_TYPE=$(ROS_DISTRIBUTION_TYPE) \
		$(UPDATER_NAME):$(DISTRO_DIR) -d $(DISTRO_DIR)
