UPDATER_NAME            = aports-ros-updater
ALPINE_VERSION         ?= 3.11
ROS_DISTRO             ?= noetic
ROS_PYTHON_VERSION     ?= 3

DISTRO_DIR              = $(ROS_DISTRO)$(shell \
  if [ $(ROS_DISTRO) = "noetic" ] && [ $(ALPINE_VERSION) != "3.11" ]; then \
    echo -n ".v$(ALPINE_VERSION)"; \
  fi)

.PHONY: build-updater
build-updater:
	docker build -t $(UPDATER_NAME):$(ALPINE_VERSION) \
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
		$(UPDATER_NAME):$(ALPINE_VERSION) $(DISTRO_DIR)

.PHONY: $(DISTRO_DIR)-dry
$(DISTRO_DIR)-dry:
	docker run --rm \
		-v ${HOME}/.netrc:/root/.netrc:ro \
		-e ROS_PYTHON_VERSION=$(ROS_PYTHON_VERSION) \
		$(UPDATER_NAME):$(ALPINE_VERSION) -d $(DISTRO_DIR)
