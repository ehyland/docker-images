- [Examples Usages](#examples-usages)
  - [Simple Nodejs](#simple-nodejs)
  - [Remix Usage](#remix-usage)

## Examples Usages

### Simple Nodejs

```Dockerfile
FROM ehyland/node-auto:debian-12 as base

# install node
COPY --chown=app:app .nvmrc ./
RUN /docker/setup-env.sh

# install deps
COPY --chown=app:app package.json pnpm-lock.yaml ./
RUN --mount=type=cache,uid=1000,gid=1000,id=pnpm,target=/home/app/.pnpm \
  pnpm install --prefer-offline

COPY --chown=app:app . .
RUN pnpm run build
RUN pnpm prune --prod
```

### Remix Usage

```Dockerfile
FROM ehyland/node-auto:debian-12 as base

# install node
COPY --chown=app:app .nvmrc ./
RUN /docker/setup-env.sh

FROM base as builder

# install deps
COPY --chown=app:app package.json pnpm-lock.yaml ./
RUN --mount=type=cache,uid=1000,gid=1000,id=pnpm,target=/home/app/.pnpm \
  pnpm install --prefer-offline

COPY --chown=app:app . .
RUN pnpm run build
RUN pnpm prune --prod

FROM base

COPY --from=builder /app/node_modules /app/node_modules
COPY --from=builder /app/build /app/build
COPY --from=builder /app/public /app/public

ENV PORT 8080

CMD [ "/app/node_modules/.bin/remix-serve", "build" ]
```
