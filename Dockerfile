FROM ruby:2.2.4

COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

# below come instructions for Hydra OMS deployment
WORKDIR /opt

RUN apt-get update \
 && apt-get install -y git \
           libpq-dev \
           nodejs \
           libqtwebkit-dev


COPY Gemfile Gemfile.lock Rakefile config.ru /opt/homs/
COPY app/      /opt/homs/app/
COPY bin/      /opt/homs/bin/
COPY config/   /opt/homs/config/
COPY db/       /opt/homs/db/
COPY fixtures/ /opt/homs/fixtures/
COPY hbw/      /opt/homs/hbw/
COPY lib/      /opt/homs/lib/
COPY public/   /opt/homs/public/
COPY spec/     /opt/homs/spec/
COPY vendor/   /opt/homs/vendor/

WORKDIR /opt/homs

RUN gem install bundler
RUN bundle --without oracle
RUN find config -name '*.sample' | xargs -I{} sh -c 'cp $1 ${1%.*}' -- {}
RUN mkdir /tmp/config
RUN cp -r /opt/homs/config/* /tmp/config
EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]
