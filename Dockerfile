# kali or kali-bleeding-edge
ARG KALI_VER=rolling
FROM amitie10g/kali-$KALI_VER:upstream AS base-build

ARG DEBIAN_FRONTEND=noninteractive

ARG DEBIAN_FRONTEND=noninteractive
COPY init/ /etc/my_init.d/
COPY kalitorify /tmp/kalitorify
COPY excludes /etc/dpkg/dpkg.cfg.d/

# Base system plus nano, lynx, tor and kalitorify

    cd /tmp/kalitorify && make install

# Desktop
FROM base-build AS desktop-build
RUN apt-get install -y kali-desktop-xfce xrdp dbus-x11 && apt-get clean

# Desktop plus Top 10
FROM desktop-build AS desktop-top10-build
RUN apt-get install -y kali-tools-top10 maltego && dpkg-reconfigure wireshark-common && apt-get clean

# Tools on top of Desktop top 10
FROM desktop-top10-build AS tool-build
ARG TOOL=exploitation
RUN apt-get install -y kali-tools-$TOOL && apt-get clean

# Vulnerable webapps
FROM base-build AS labs-build
RUN apt-get install -y kali-linux-labs && apt-get clean && \
    sed -i '/allow 127.0.0.1;/a \\t    allow 172.16.0.0/12;' /etc/dvwa/vhost/dvwa-nginx.conf
COPY init.d/dvwa init.d/juice-shop /etc/init.d/

# Headless
FROM base-build AS headless-build
RUN apt-get install -y kali-linux-headless && apt-get clean

# Nethunter
FROM base-build AS nethunter-build
RUN apt-get install -y kali-linux-nethunter && apt-get clean

# Cleanup
FROM base-build AS base
COPY init/ /etc/my_init.d/
RUN rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
WORKDIR /root

FROM desktop-build AS desktop
COPY init/ /etc/my_init.d/
RUN rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
WORKDIR /root

FROM desktop-top10-build AS desktop-top10
COPY init/ /etc/my_init.d/
RUN rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
WORKDIR /root

FROM labs-build AS labs
COPY init/ /etc/my_init.d/
RUN rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
WORKDIR /root

FROM headless-build AS headless
COPY init/ /etc/my_init.d/
RUN rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
WORKDIR /root

FROM nethunter-build AS nethunter
COPY init/ /etc/my_init.d/
RUN rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
WORKDIR /root

FROM tool-build AS tool
COPY init/ /etc/my_init.d/
RUN rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
WORKDIR /root
