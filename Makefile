TAG = $(shell git describe --tags)
UNAME = $(shell uname)

deps:
	curl -L https://github.com/progrium/dockerhub-tag/releases/download/v0.2.0/dockerhub-tag_0.2.0_$(UNAME)_x86_64.tgz | tar -xzC /usr/local/bin
dockerhub-tag:
	echo dockerhub-tag set  sequenceiq/ambari $(TAG) $(TAG) ambari-server/
