FROM elixir:1.9

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash

# Install depenencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
            inotify-tools \
            apt-transport-https \
            apt-utils \
            postgresql-client \
            nodejs

# Install yarn
RUN npm install -g yarn

# Create openpace user and group from host to avoid permission issues
ARG HOST_GROUP_GID
ARG HOST_USER_UID
RUN addgroup --gid $HOST_GROUP_GID openpace && \
    useradd -m -u $HOST_USER_UID -g $HOST_GROUP_GID openpace

# Set permissions to the app folder
ARG APP_DIR='/app'
RUN mkdir -p $APP_DIR && \
    chown -R openpace:openpace $APP_DIR

USER openpace

RUN mix local.hex --force && mix local.rebar --force

WORKDIR $APP_DIR

ENTRYPOINT ["sh", "/app/docker/entrypoint.sh"]
