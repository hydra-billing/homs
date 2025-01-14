FROM ruby:3.2.6-slim-bullseye

RUN mkdir -p /opt/homs

RUN useradd --uid 2004 --home /opt/homs --shell /bin/bash --comment "HOMS" homs && \
  chown -R homs /opt/homs

RUN apt-get update -q && \
  apt-get purge -y cmdtest && \
  apt-get install --no-install-recommends -yq wget gnupg

RUN seq 1 8 | xargs -I{} mkdir -p /usr/share/man/man{} && \
  wget -O - http://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  wget -qO- https://deb.nodesource.com/setup_18.x | bash -

RUN apt-get update && apt-get install --no-install-recommends -y \
  build-essential \
  curl \
  git \
  libpq-dev \
  libxml2-dev \
  libxml2 \
  libxslt-dev \
  libyaml-dev \
  make \
  nodejs \
  postgresql-client \
  pkg-config \
  ruby-dev \
  telnet \
  yarn

ENV NLS_LANG=AMERICAN_RUSSIA.AL32UTF8



USER homs
WORKDIR /opt/homs

COPY --chown=homs Gemfile Gemfile.lock Rakefile config.ru package.json yarn.lock .eslintrc .babelrc tsconfig.json /opt/homs/
COPY --chown=homs hbw/*.gemspec /opt/homs/hbw/
COPY --chown=homs hbw/lib/hbw/  /opt/homs/hbw/lib/hbw/

ENV NOKOGIRI_USE_SYSTEM_LIBRARIES 1
ENV REDIS_HOST                    redis
ENV REDIS_PORT                    6379

RUN gem install bundler
RUN bundle config --global frozen 1
RUN bundle --without oracle test

COPY --chown=homs app/      /opt/homs/app/
COPY --chown=homs bin/      /opt/homs/bin/
COPY --chown=homs config/   /opt/homs/config/
COPY --chown=homs db/       /opt/homs/db/
COPY --chown=homs fixtures/ /opt/homs/fixtures/
COPY --chown=homs lib/      /opt/homs/lib/
COPY --chown=homs public/   /opt/homs/public/
COPY --chown=homs spec/     /opt/homs/spec/
COPY --chown=homs vendor/   /opt/homs/vendor/
COPY --chown=homs hbw/      /opt/homs/hbw/

COPY --chown=homs ./entrypoint.sh ./wait_for_postgres.sh /

USER root

ARG VERSION

RUN echo $VERSION > /opt/homs/VERSION

RUN find config -name '*.sample' | xargs -I{} sh -c 'cp $1 ${1%.*}' -- {}
RUN mkdir /tmp/config
RUN chown -R homs /opt/homs/config
RUN cp -r /opt/homs/config/* /tmp/config

EXPOSE 3000

USER homs

RUN yarn install && \
  yarn lint && \
  yarn build && \
  rm -rf /opt/homs/node_modules/

WORKDIR /opt/homs
ENTRYPOINT ["/entrypoint.sh"]
