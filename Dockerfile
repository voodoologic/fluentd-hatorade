FROM ubuntu:14.04
MAINTAINER Doug Headley <headley.douglas@gmail.com>

LABEL Description="Fluentd docker image" Vendor="Fluent Organization" Version="1.0"

RUN apt-get update -y && apt-get install -y \
              autoconf \
              bison \
              build-essential \
              curl \
              git \
              libffi-dev \
              libgdbm3 \
              libgdbm-dev \
              libncurses5-dev \
              libreadline6-dev \
              libssl-dev \
              libyaml-dev \
              zlib1g-dev \
        && rm -rf /var/lib/apt/lists/*

# Install ruby
ENV RUBY_VERSION=2.2.3
RUN curl -O http://ftp.ruby-lang.org/pub/ruby/2.2/ruby-${RUBY_VERSION}.tar.gz && \
    tar -zxvf ruby-${RUBY_VERSION}.tar.gz && \
    cd ruby-${RUBY_VERSION} && \
    ./configure --disable-install-doc --enable-shared && \
    make && \
    make install && \
    cd .. && \
    rm -r ruby-${RUBY_VERSION} ruby-${RUBY_VERSION}.tar.gz && \
    echo 'gem: --no-document' > /usr/local/etc/gemrcdoc

# for log storage (maybe shared with host)
RUN mkdir -p /fluentd/log
# configuration/plugins path (default: copied from .)
RUN mkdir -p /fluentd/etc
RUN mkdir -p /fluentd/plugins

RUN gem install fluentd
RUN gem install fluent-plugin-elasticsearch

COPY fluent.conf /fluentd/etc/
ONBUILD COPY fluent.conf /fluentd/etc/
ONBUILD COPY plugins /fluentd/plugins/

WORKDIR /root

ENV FLUENTD_OPT=""
ENV FLUENTD_CONF="fluent.conf"

EXPOSE 24224

### docker run -p 24224 -v `pwd`/log: -v `pwd`/log:/root/log fluent/fluentd:latest
CMD exec fluentd -c /fluentd/etc/$FLUENTD_CONF -p /fluentd/plugins $FLUENTD_OPT
