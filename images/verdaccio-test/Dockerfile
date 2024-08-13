FROM node:lts-alpine

RUN apk add --no-cache \
  bash \
  curl \
  yq \
  shadow

# create user workspace
RUN mkdir \
  /verdaccio \
  /docker \
  && chown -R node:node \
  /verdaccio \
  /docker \
  # allow global npm installs from user node (don't do this for a prod image)
  /usr/local/lib/node_modules/ \
  /usr/local/bin/ 

WORKDIR /verdaccio

ARG VERDACCIO_VERSION=5.15.3
RUN npm i -g verdaccio@${VERDACCIO_VERSION}

COPY --chown=node:node ./docker /docker
COPY --chown=node:node ./verdaccio /verdaccio

RUN chmod +x /docker/*.sh

ENTRYPOINT [ "/docker/entrypoint.sh" ]
CMD [ "/docker/command.sh" ]