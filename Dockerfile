FROM ruby:2.5.1-slim

RUN mkdir -p /opt/homs

RUN apt-get update && apt-get install --no-install-recommends -y \
  build-essential \
  git \
  libpq-dev \
  libxml2-dev \
  libxml2 \
  libxslt-dev \
  make \
  nodejs \
  postgresql-client \
  pkg-config \
  ruby-dev

ENV NLS_LANG=AMERICAN_RUSSIA.AL32UTF8

RUN useradd --uid 2004 --home /opt/homs --shell /bin/bash --comment "HOMS" homs

USER homs
WORKDIR /opt/homs

COPY Gemfile Gemfile.lock Rakefile config.ru /opt/homs/
COPY hbw/ /opt/homs/hbw/
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES=1

RUN gem install bundler
RUN bundle config --global frozen 1
RUN bundle --without oracle test

COPY app/      /opt/homs/app/
COPY bin/      /opt/homs/bin/
COPY config/   /opt/homs/config/
COPY db/       /opt/homs/db/
COPY fixtures/ /opt/homs/fixtures/
COPY lib/      /opt/homs/lib/
COPY public/   /opt/homs/public/
COPY spec/     /opt/homs/spec/
COPY vendor/   /opt/homs/vendor/

COPY ./entrypoint.sh ./wait_for_postgres.sh /

USER root

RUN chown -R homs:homs /opt/homs
RUN chmod +x /entrypoint.sh /wait_for_postgres.sh

RUN find config -name '*.sample' | xargs -I{} sh -c 'cp $1 ${1%.*}' -- {}
RUN mkdir /tmp/config
RUN cp -r /opt/homs/config/* /tmp/config

EXPOSE 3000

USER homs
WORKDIR /opt/homs
ENTRYPOINT ["/entrypoint.sh"]
