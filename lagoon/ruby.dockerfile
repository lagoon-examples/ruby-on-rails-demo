FROM uselagoon/ruby-3.3:latest

ENV LAGOON=ruby

RUN apk add --no-cache --virtual .build-deps \
      build-base sqlite sqlite-dev \
      curl-dev curl ruby-dev make \
      zlib-dev libxml2-dev libxslt-dev tzdata yaml-dev sqlite-dev postgresql-dev mysql-dev \
      ruby ruby-io-console ruby-json yaml nodejs \
    && gem install webrick puma bundler \
    && apk add --no-cache \
        postgresql-client \
        rsync \
        tar \
    && rm -rf /var/cache/apk/*

WORKDIR /app
COPY . /app
RUN bundle install

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
