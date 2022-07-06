TAG ?= latest
IMAGE ?= jvassev/chrome
CONT ?= tight-driver-cont


build:
	docker build -t $(IMAGE):$(TAG) .

push: build
	docker push $(IMAGE):$(TAG)

run: rm build
	docker run -dt --name $(CONT) \
	  -p 5900 \
	  -p 6080 \
	  -e SESSION_NAME=devmode \
	 $(IMAGE)

	@make info

rm: stop
	docker rm -f -v $(CONT) || true

attach:
	docker exec -ti $(CONT) /bin/bash

start:
	docker start $(CONT)

stop:
	docker stop -t 3 $(CONT) || docker kill $(CONT) || true

logs:
	docker logs -f $(CONT)

shell:
	@docker run --rm -ti \
	  --entrypoint=/bin/bash --user=root \
	  $(IMAGE)

inspect:
	@docker inspect $(CONT)

vnc:
	bash -c "vncviewer -passwd <(echo 123456 | vncpasswd -f) `docker inspect --format='{{.NetworkSettings.IPAddress}}:5901' $(CONT)`"

info:
	@echo -n "vncviewer "
	@docker inspect --format='{{.NetworkSettings.IPAddress}}:5900' $(CONT)
	@echo -n "vncviewer localhost:"
	@docker inspect --format='{{(index (index .NetworkSettings.Ports "5900/tcp") 0).HostPort }}' $(CONT)
	@echo -n "firefox http://localhost:"
	@docker inspect --format='{{(index (index .NetworkSettings.Ports "6080/tcp") 0).HostPort }}' $(CONT)
