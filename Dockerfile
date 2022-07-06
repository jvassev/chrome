FROM ubuntu:bionic

ENV VNC_SCREEN_SIZE 1920x1200
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

EXPOSE 5900 6080
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]


RUN apt-get update \
	&& apt-get install -y \
	gnupg2 \
	curl \
	fonts-noto-cjk \
	pulseaudio \
	supervisor \
	python3 \
	x11vnc \
	fluxbox \
	git \
	xvfb \
	eterm

# Install Google Chrome
RUN curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
	echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list && \
	apt-get -y update && \
	apt-get -y install google-chrome-stable && \
	rm -rf /var/lib/apt/lists/*

COPY copyables /

RUN apt-get clean \
	&& rm -rf /var/cache/* /var/log/apt/* /var/lib/apt/lists/* /tmp/* \
	&& useradd -m -G pulse-access chrome \
	&& usermod -s /bin/bash chrome \
	&& mkdir -p /home/chrome/.fluxbox /home/chrome/.config \
	&& echo ' \n\
	session.screen0.toolbar.visible:        false\n\
	session.screen0.fullMaximization:       true\n\
	session.screen0.maxDisableResize:       true\n\
	session.screen0.maxDisableMove: true\n\
	session.screen0.defaultDeco:    NONE\n\
	' >> /home/chrome/.fluxbox/init \
	&& chown -R chrome:chrome /home/chrome/.config /home/chrome/.fluxbox

RUN git clone https://github.com/kanaka/noVNC.git    /home/chrome/novnc  && \
	cd /home/chrome/novnc && git checkout v1.1.0 && \
	rm -fr .git && \
	git clone https://github.com/kanaka/websockify.git --depth 1 /home/chrome/novnc/utils/websockify

COPY vnc_auto.html  /home/chrome/novnc/index.html