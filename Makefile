MSCS_USER := minecraft
MSCS_GROUP := minecraft
MSCS_HOME := /opt/mscs

MSCTL := /usr/local/bin/msctl
MSCS := /usr/local/bin/mscs
MSCS_INIT_D := /etc/init.d/mscs
MSCS_SERVICE := /etc/systemd/system/mscs.service
MSCS_COMPLETION := /etc/bash_completion.d/mscs

.PHONY: docker-build docker-run install update clean

docker-build:
	docker build -t egut/mscs .
	docker build -t myworld myWorld

docker-run: docker-build
	docker run -t -p 25565:25565 --name=myworld -d myworld

install: $(MSCS_HOME) update
	adduser --system --group --home $(MSCS_HOME) --quiet $(MSCS_USER)
	chown -R $(MSCS_USER):$(MSCS_GROUP) $(MSCS_HOME)
	if which systemctl; then \
		systemctl -f enable mscs.service; \
	else \
		ln -s $(MSCS) $(MSCS_INIT_D); \
		update-rc.d mscs defaults; \
	fi

update:
	cp msctl $(MSCTL)
	cp mscs $(MSCS)
	cp mscs.completion $(MSCS_COMPLETION)
	if which systemctl; then \
		cp mscs.service $(MSCS_SERVICE); \
	fi

clean:
	if which systemctl; then \
		systemctl -f disable mscs.service; \
		rm -f $(MSCS_SERVICE); \
	else \
		update-rc.d mscs remove; \
		rm -f $(MSCS_INIT_D); \
	fi
	rm -f $(MSCTL) $(MSCS) $(MSCS_COMPLETION)

$(MSCS_HOME):
	mkdir -p -m 755 $(MSCS_HOME)
