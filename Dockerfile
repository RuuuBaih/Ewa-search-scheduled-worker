FROM ruuubaih2020soa/ruby-http:2.7.1

WORKDIR /worker

COPY / .

RUN apk update && apk upgrade
RUN apk add sqlite sqlite-dev
RUN apk add postgresql-client postgresql-dev

RUN bundle install

CMD rake worker

# LOCAL:
# Build local image with:
#   rake docker:build
# or:
#   docker build --rm --force-rm -t ruuubaih2020soa/search_worker:0.1.0 .
#
# Run and test local container with:
#   rake docker:run
# or:
#   docker run -e --rm -it -v $(pwd)/config:/worker/config -w /worker ruuubaih2020soa/search_worker:0.1.0 ruby worker/search_worker.rb

# REMOTE:
# Make sure Heroku app exists:
#   heroku create search-scheduled_worker
#
# Build and push to Heroku container registry with:
#   heroku container:push web
# (if first time, add scheduler addon to Heroku and have it run 'worker')
#
# Run and test remote container:
#   heroku run worker
# or:
#   heroku run ruby worker/search_worker.rb