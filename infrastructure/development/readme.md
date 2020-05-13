# Development Infrastructure

This directory contains development infrastructure provision scripts, mainly for debugging.

## Usage

We need `terraform` and `docker`, so use `brew install terraform` to install terraform CLI and get latest distribution of docker form [docker.com](https://www.docker.com/products/docker-desktop).

Next, set `docker_registry_token` variable to github personal access token with _read_ permission to packages. Create `terraform.tfvars` file in current directory with the personal access token.

```tf
# terraform.tfvars
docker_registry_token = "xxxxxxxxxxxxx"
```

Make sure kubernetes is enabled in docker. You can find kubernetes config in docker preferences.

Run `terraform apply` from current directory, e.g. `<projectRoot>/infrastructure/development`.
