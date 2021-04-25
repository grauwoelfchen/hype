# Hype

An interface to interact with Discord via API.

## Repositories

This is mainly developed on [GitLab.com](
https://gitlab.com/grauwoelfchen/hype), but the source code is hosted also
in several following repositories.

Any merge/pull requests or issues on any repository are welcomed.

* https://gitlab.com/grauwoelfchen/hype
* https://github.com/grauwoelfchen/hype
* https://git.sr.ht/~grauwoelfchen/hype

```zsh
# the main branch is "trunk"
% git clone git@gitlab.com:grauwoelfchen/hype.git
% git --no-pager branch -v
* trunk xxxxxxx XXX
```

## Installation

TODO

## Usage

```zsh
% echo "CLIENT_ID=\"...\"\nCLINET_SECRET=\"...\"" > .env
% hype
```

## Development

### Verify

```zsh
# check code using all verify:xxx targets
% make verify:all
```

### Test

```zsh
% make test
```

### CI

Run CI jobs on a docker conatiner (grauwoelfchen/rust-stable: Gentoo Linux)
using gitlab-runner. See `.gitlab-ci.yml`.

#### Run jobs on local machine

```zsh
# install gitlab-runner into .tools
% .tool/setup-gitlab-runner

# prepare environment variables for CI via .env.ci
% cp .env.ci.sample .env

# e.g. test (see .gitlab-ci.yml)
% .tool/ci-runner test
```


## Release

All notable released changes of this package will be documented in CHANGELOG
file.

### Unreleased commits

[v0.0.1...trunk](
https://gitlab.com/grauwoelfchen/hype/compare/v0.0.1...trunk)


## License

`GPL-3.0-or-later`

```txt
Hype
Copyright 2021 Yasuhiro Яша Asaka

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
```
