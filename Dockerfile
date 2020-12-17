FROM ruby:2.6.5-slim

RUN mkdir -p /opt/homs

RUN apt-get update -q && apt-get purge -y cmdtest && apt-get install --no-install-recommends -yq wget gnupg

RUN seq 1 8 | xargs -I{} mkdir -p /usr/share/man/man{} && wget -O - http://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && wget -qO- https://deb.nodesource.com/setup_10.x | bash -

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
  ruby-dev \
  yarn \
  curl \
  telnet

ENV NLS_LANG=AMERICAN_RUSSIA.AL32UTF8

RUN useradd --uid 2004 --home /opt/homs --shell /bin/bash --comment "HOMS" homs

RUN chown homs:homs /opt/homs

USER homs
WORKDIR /opt/homs

COPY --chown=homs:homs Gemfile Gemfile.lock Rakefile config.ru package.json yarn.lock .eslintrc /opt/homs/
COPY --chown=homs:homs hbw/*.gemspec /opt/homs/hbw/
COPY --chown=homs:homs hbw/lib/hbw/ /opt/homs/hbw/lib/hbw/
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES=1
ENV MEMCACHED_URL memcached

RUN gem install bundler
RUN bundle config --global frozen 1
RUN bundle --without oracle test

COPY --chown=homs:homs app/      /opt/homs/app/
COPY --chown=homs:homs bin/      /opt/homs/bin/
COPY --chown=homs:homs config/   /opt/homs/config/
COPY --chown=homs:homs db/       /opt/homs/db/
COPY --chown=homs:homs fixtures/ /opt/homs/fixtures/
COPY --chown=homs:homs lib/      /opt/homs/lib/
COPY --chown=homs:homs public/   /opt/homs/public/
COPY --chown=homs:homs spec/     /opt/homs/spec/
COPY --chown=homs:homs vendor/   /opt/homs/vendor/
COPY --chown=homs:homs hbw/      /opt/homs/hbw/

COPY --chown=homs:homs ./entrypoint.sh ./wait_for_postgres.sh /

USER root

ARG VERSION

RUN echo $VERSION > /opt/homs/VERSION

RUN chown -R homs:homs /opt/homs
RUN chmod +x /entrypoint.sh /wait_for_postgres.sh

RUN find config -name '*.sample' | xargs -I{} sh -c 'cp $1 ${1%.*}' -- {}
RUN mkdir /tmp/config
RUN cp -r /opt/homs/config/* /tmp/config

EXPOSE 3000

USER homs

RUN yarn install && yarn lint && bundle exec rails assets:precompile && rm -rf /opt/homs/node_modules/

WORKDIR /opt/homs
ENTRYPOINT ["/entrypoint.sh"]
