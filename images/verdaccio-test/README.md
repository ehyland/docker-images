# verdaccio-test

A [Verdaccio](https://verdaccio.org/) npm registry packaged for testing npm
publish and install flows. It is **not** intended for production use.

Images are published as `ehyland/verdaccio-test:<verdaccio-version>`, where the
tag matches the upstream Verdaccio version (for example
`ehyland/verdaccio-test:7.0.2`).

- [Usage](#usage)
  - [Docker Compose](#docker-compose)
  - [Authentication](#authentication)
- [Environment variables](#environment-variables)
- [Persistence](#persistence)
- [Building and testing](#building-and-testing)
- [How the test works](#how-the-test-works)
- [Notes](#notes)

## Usage

### Docker Compose

```yaml
services:
  registry:
    image: ehyland/verdaccio-test:7.0.2
    environment:
      VERDACCIO_UID: 1000
      VERDACCIO_PORT: 4873
    ports:
      - "4873:4873"
    volumes:
      - ./data:/verdaccio/storage/data
```

```bash
docker compose up -d registry

# write registry + auth token to .npmrc
docker compose run --rm registry npmrc localhost:4873 > .npmrc

npm publish
npm install <package>
```

The registry is configured to allow anonymous access and publishing
(`access: $all`, `publish: $all`) and proxies uncached packages to npmjs.

### Authentication

npm requires credentials to publish, even when the registry allows anonymous
publishing. The image prints a static, non-expiring JWT for this purpose:

```bash
# full .npmrc entry (registry + token)
docker compose run --rm registry npmrc localhost:4873

# token entry only
docker compose run --rm registry auth
```

Both commands work without the registry running. The token is signed with the
image's fixed test secret, so it is only suitable for test registries.

## Environment variables

| Variable                         | Default                    | Description                                                                 |
| -------------------------------- | -------------------------- | --------------------------------------------------------------------------- |
| `VERDACCIO_PORT`                 | `4873`                     | Port the registry listens on.                                               |
| `VERDACCIO_UID`                  | UID of `node` (`1000`)     | UID to run the registry as. Storage files are chowned to this user.         |
| `VERDACCIO_NO_NPM_PROXY_PACKAGE` | unset                      | Package name to configure without the npmjs proxy.                          |

## Persistence

| Path                             | Description                                                      |
| -------------------------------- | ---------------------------------------------------------------- |
| `/verdaccio/storage/data`        | Package storage and `.verdaccio-db.json`. Mount this to persist. |
| `/verdaccio/storage/htpasswd`    | htpasswd file used by the `htpasswd` auth plugin.                |
| `/verdaccio/config.yml`          | Verdaccio configuration. Mount a writable copy to override it.    |
| `/verdaccio/plugins`             | Plugin directory (empty by default).                             |

## Building and testing

From the repository root (requires Docker with Compose, `curl`, and `yq`):

```bash
./scripts/build images/verdaccio-test
```

This resolves the latest Verdaccio version, builds
`ehyland/verdaccio-test:<version>`, runs the publish test, and pushes the image
when running in CI.

To build manually:

```bash
docker build \
  --build-arg VERDACCIO_VERSION=7.0.2 \
  -t ehyland/verdaccio-test:7.0.2 \
  images/verdaccio-test
```

## How the test works

`images/verdaccio-test/scripts/test.sh`:

1. Copies `fixtures/docker-compose-project` to `test-workspace`.
2. Generates `.npmrc` with the static auth token via the image's `npmrc`
   command.
3. Starts the registry and a `node:latest` test runner with Docker Compose.
4. Publishes a package named `basic-package` to the registry.
5. Verifies the registry's storage files are owned by `VERDACCIO_UID` (`1000`).

## Notes

- This image is for testing only. It deliberately allows anonymous publishing
  and uses a fixed, non-expiring auth token.
- Verdaccio 7 rejects invalid bearer tokens with `401`, so the static token is a
  real JWT (configured under `security.api.jwt` in `verdaccio/config.yml`)
  rather than an arbitrary string.
- The token is defined as `STATIC_AUTH_TOKEN` in `docker/entrypoint.sh` and is
  signed with the fixed `SECRET` there. If you change `SECRET`, regenerate the
  token with the same `groups` claim (`$all`, `$auth`, `$deprecated_all`,
  `$deprecated_auth`, `all`).
