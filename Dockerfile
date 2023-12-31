FROM phusion/passenger-ruby32:latest
ENV TZ=America/New_York
ENV DEBIAN_FRONTEND noninteractive
ARG APP_ID_NAME=app

COPY --chown=app:app . /home/app/webapp
COPY /configureDB.sh /docker-entrypoint-initdb.d
RUN apt-get update -qq && \
    apt-get install python3-dev git -y && \
    apt-get install -y \
                       cmake \
                       gcc \
                       pkg-config \
                       zlib1g-dev \
                       netcat \
                       build-essential \
                       libssl-dev \
                       libcurl4-openssl-dev \
                       libreadline-dev \
                       libyaml-dev \
                       libxml2-dev \
                       libxslt1-dev \
                       libcurl4-openssl-dev \
                       software-properties-common \
                       shared-mime-info \
                       libffi-dev \
                       nodejs \
                       yarn \
                       imagemagick \
                       libpq-dev \
                       libsasl2-dev \
                       mariadb-client \
                       rsync \
                       tzdata \
                       unzip \
                       && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -f /etc/nginx/sites-enabled/default && \
    rm -f /etc/service/nginx/down && \
    chmod +x /home/app/webapp/bin/*.sh && \
    chown app /etc/ssl/certs && \
    chown app /etc/ssl/openssl.cnf && \
    chown -R app:app /etc/container_environment && \
    chmod -R 755 /etc/container_environment && \
    chown app:app /etc/container_environment.sh /etc/container_environment.json && \
    chmod 644 /etc/container_environment.sh /etc/container_environment.json && \
    chown -R app:app /var/log/nginx && \
    chown -R app:app /var/lib/nginx && \
    chown -R app:app /run  


USER root

WORKDIR /home/app/webapp

RUN gem update --system && \
    bundle install && \
    mkdir -p /home/app/webapp/tmp/cache/downloads && \
    chmod g+s /home/app/webapp/tmp/cache && \
    chmod 755 /home/app/webapp/tmp/cache/downloads && \
    mkdir -p /home/app/webapp/tmp/pids

CMD ["passenger", "start", "--port", "3000", "--log-file", "/dev/stdout", "--no-install-runtime", "--no-compile-runtime","--max-pool-size", "15" ,"mysqld", "--min-instances", "15", "--nginx-config-template","ops/nginx.conf.erb"]
