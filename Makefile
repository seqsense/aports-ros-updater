UPDATER_NAME            = aports-ros-updater
TARGETS                ?= 3.7.kinetic 3.8.melodic
OPTIONS                 =

.PHONY: $(TARGETS)
$(TARGETS):
	docker build -t $(UPDATER_NAME):$(basename $@) .
	docker run --rm -it \
		-v ${HOME}/.netrc:/root/.netrc:ro \
		-e ROS_DISTRO=$(subst .,,$(suffix $@)) \
		$(UPDATER_NAME):$(basename $@) $(OPTIONS)
