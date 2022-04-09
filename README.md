# [ds-nix](#)

> nix overlays

[![Nix: Coverage](https://github.com/sambacha/nix-template/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/sambacha/nix-template/actions/workflows/test.yml) [![niv auto update](https://github.com/sambacha/nix-template/actions/workflows/update-niv.yml/badge.svg?branch=master)](https://github.com/sambacha/nix-template/actions/workflows/update-niv.yml)

## Overivew

All tools in this directory are built with `nix`, a declarative package manager which gives a secure and predictable bundling of dependencies.

They are defined as attributes in the `./overlay.nix` file, which in turn imports the `default.nix` file of each tool.

The dependencies of each tool is set as `buildInputs` in the `default.nix` file.


## Getting started

Install Nix if you haven't already ([instructions](https://nixos.org/download.html)). Then install dapptools:

```shell
curl https://dapp.tools/install | sh
```


## Using Cacheix

```yml
# Cachix Workflow
name: "cachix"
on:
  pull_request:
  push:
jobs:
  tests:
    runs-on: ubuntu-latest
    steps:
      - uses: cachix/install-nix-action@latest
      - uses: cachix/cachix-action@latest
        with:
          name: nix-getting-started-template
          signingKey: "${{ secrets.CACHIX_SIGNING_KEY }}"
          # Only needed for private caches
          #authToken: '${{ secrets.CACHIX_AUTH_TOKEN }}'
      - run: nix-build https://github.com/$GITHUB_REPOSITORY/archive/$GITHUB_SHA.tar.gz
      - run: nix-shell https://github.com/$GITHUB_REPOSITORY/archive/$GITHUB_SHA.tar.gz --run "echo OK"
```
