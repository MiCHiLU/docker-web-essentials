FROM mhart/alpine-node-auto:0.10.48

# bash needed by the steps on Wercker CI
# ruby, ruby-dev, and ruby-io-console needed by gem
RUN apk --no-cache --update add \
  bash \
  git \
  make \
  python \
  python-dev \
  rsync \
  ruby \
  ruby-dev \
  ruby-io-console \
  sudo \
  ;

ENV \
  HOME="/root" \
  LC_CTYPE="C.utf8"
WORKDIR $HOME

# for Ruby gem
ADD gemrc /etc/
RUN gem install \
  bundler \
  && rm -r $HOME/.gem \
  && find / -type f -name "*.gem" -delete \
  ;
# gcc and libc-dev libffi-dev needed by gem install ffi
RUN apk --no-cache --update add --virtual=build-time-only \
  gcc \
  libc-dev \
  libffi-dev \
  && gem install \
  ffi \
  && rm -r $HOME/.gem \
  && find / -type f -name "*.gem" -delete \
  && apk del build-time-only \
  ;

# for Python PIP
RUN apk --no-cache --update add --virtual=build-time-only \
  curl \
  && curl -s https://bootstrap.pypa.io/get-pip.py | python \
  && apk del build-time-only \
  ;

# pre install
ADD Gemfile $HOME/
ADD package.json $HOME/
RUN \
  npm instal \
  && rm package.json \
  && bundle install \
  && rm Gemfile* \
  ;

ENV PATH="$HOME/node_modules/.bin:$PATH"

CMD echo "print versions..."\
  && coffee --version \
  && compass --version \
  && haml --version \
  && sass --version \
  && uglifyjs --version \
  ;
