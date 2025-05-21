# CfnFlip

[![Hackage](https://img.shields.io/hackage/v/cfn-flip.svg?style=flat)](https://hackage.haskell.org/package/cfn-flip)
[![Stackage Nightly](http://stackage.org/package/cfn-flip/badge/nightly)](http://stackage.org/nightly/package/cfn-flip)
[![Stackage LTS](http://stackage.org/package/cfn-flip/badge/lts)](http://stackage.org/lts/package/cfn-flip)
[![CI](https://github.com/freckle/cfn-flip/actions/workflows/ci.yml/badge.svg)](https://github.com/pbrisbin/freckle/cfn-flip/workflows/ci.yml)

Pure Haskell implementation of [cfn-flip][].

[cfn-flip]: https://github.com/awslabs/aws-cfn-template-flip

## Usage

See [CfnFlip.hs](./src/CfnFlip.hs).

## Release

To release a new version of this library, push a commit to `main` using a
[conventionally-formatted][conventionalcommmits] commit message.

- Prefix with `fix:` to release a new patch version,
- Prefix with `feat:` to release a new minor version, or
- Use `<type>!:` or a `BREAKING CHANGE:` footer to release a new major version

[conventionalcommmits]: https://www.conventionalcommits.org/en/v1.0.0/

---

[LICENSE](./LICENSE) | [CHANGELOG](./CHANGELOG.md)
