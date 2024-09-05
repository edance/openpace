ARG ELIXIR_VERSION=1.14.2
ARG OTP_VERSION=24.3.4.8
ARG DEBIAN_VERSION=buster-20230109-slim
ARG IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"

FROM ${IMAGE}

ARG RUST_VERSION=1.80.1

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git curl

# Get nodejs source (requires curl)
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -

# Install depenencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
            inotify-tools \
            apt-transport-https \
            apt-utils \
            postgresql-client \
            nodejs \
            python3 \
            python3-pip \
            unzip

# Install bun
RUN npm install -g bun

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

# Install Rust for openpace user to get around permission issues
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain ${RUST_VERSION}
ENV PATH="/home/openpace/.cargo/bin:${PATH}"

RUN mix local.hex --force && mix local.rebar --force

WORKDIR $APP_DIR

ENTRYPOINT ["sh", "/app/dev_docker/entrypoint.sh"]
