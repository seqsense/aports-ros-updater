UPDATER_NAME            = aports-ros-updater
ALPINE_VERSION         ?= 3.7
ROS_DISTRO             ?= kinetic

.PHONY: build-updater
build-updater:
	docker build -t $(UPDATER_NAME):$(ALPINE_VERSION) .

.PHONY: $(ROS_DISTRO)
$(ROS_DISTRO):
	docker run --rm -it \
		-v ${HOME}/.netrc:/root/.netrc:ro \
		$(UPDATER_NAME):$(ALPINE_VERSION)

.PHONY: $(ROS_DISTRO)-dry
$(ROS_DISTRO)-dry:
	docker run --rm -it \
		-v ${HOME}/.netrc:/root/.netrc:ro \
		$(UPDATER_NAME):$(ALPINE_VERSION) -d
