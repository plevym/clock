FROM ruby:2.5.1
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev git

ENV INSTALL_PATH /todos
WORKDIR $INSTALL_PATH

COPY Gemfile* $INSTALL_PATH/
COPY ./vendor $INSTALL_PATH/vendor
RUN bundle install

COPY . $INSTALL_PATH

CMD $INSTALL_PATH/run.sh