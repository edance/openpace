# Find eligible builder and runner images on Docker Hub. We use Ubuntu/Debian instead of
# Alpine to avoid DNS resolution issues in production.
#
# https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=ubuntu
# https://hub.docker.com/_/ubuntu?tab=tags
#
#
# This file is based on these images:
#
#   - https://hub.docker.com/r/hexpm/elixir/tags - for the build image
#   - https://hub.docker.com/_/debian?tab=tags&page=1&name=bullseye-20210902-slim - for the release image
#   - https://pkgs.org/ - resource for finding needed packages
#   - Ex: hexpm/elixir:1.12.3-erlang-23.3-debian-bullseye-20210902-slim
#         1.14.5-erlang-26.2.5.5-debian-bullseye-20241016-slim
#
#
ARG ELIXIR_VERSION=1.14.5
ARG OTP_VERSION=26.2.5.5
ARG DEBIAN_VERSION=bullseye-20241016-slim

ARG RUST_VERSION=1.80.1

ARG RUST_IMAGE="rust:${RUST_VERSION}"
ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"


FROM ${RUNNER_IMAGE} AS rust
# Redeclare the ARG to make it available in this stage
ARG RUST_VERSION

# Install build dependencies
RUN apt-get update -y && apt-get install -y curl build-essential git pkg-config

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain ${RUST_VERSION}

# Clean up
RUN apt-get clean && rm -f /var/lib/apt/lists/*_*

ENV PATH="/root/.cargo/bin:${PATH}"
WORKDIR /app
COPY native/rust_fit ./
RUN cargo rustc --release 


# Use the elixir image to build the release
#
FROM ${BUILDER_IMAGE} AS builder

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git curl unzip

# Get nodejs source (requires curl)
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -

# Install nodejs
RUN apt-get update -y && apt-get install -y nodejs

# Install bun
RUN npm install -g bun

# Clean up
RUN apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv

COPY lib lib

COPY assets assets

# Copy the compiled Rust code
COPY --from=rust /app/target/release/librust_fit.so priv/native/librust_fit.so

# compile assets
RUN mix assets.deploy

# Compile the release
RUN mix compile

# Build the docs
RUN mix docs

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
#
FROM ${RUNNER_IMAGE}

RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales \
  && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/squeeze ./

USER nobody

CMD ["/app/bin/server"]
# Appended by flyctl
ENV ECTO_IPV6=true
ENV ERL_AFLAGS="-proto_dist inet6_tcp"

