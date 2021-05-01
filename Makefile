PACKAGE=hype

# verify
verify\:check:  ## Verify code syntax [alias: check]
	@cargo check --all --verbose
.PHONY: verify\:check

check: | verify\:check
.PHONY: check

verify\:format:  ## Verify format without changes [alias: verify:fmt, format, fmt]
	@cargo fmt --all -- --check
.PHONY: verify\:format

format: | verify\:format
.PHONY: format

fmt: | verify\:format
.PHONY: fmt

verify\:lint:  ## Verify coding style using clippy [alias: lint]
	@cargo clippy --all-targets
.PHONY: verify\:lint

lint: | verify\:lint
.PHONY: lint

verify\:all: | verify\:check verify\:format verify\:lint  ## Check code using all verify:xxx targets [alias: verify]
.PHONY: verify\:all

verify: | verify\:all
.PHONY: verify

# test
test\:all:  ## Run all unit tests [alias: test]
	@cargo test --tests
.PHONY: test\:all

test: | test\:all
.PHONY: test

# coverage
coverage:  ## Generate coverage report of tests [alias: cov]
	@cargo test --bin $(PACKAGE) --no-run
	@set -uo pipefail; \
	dir="$$(pwd)"; \
	output_dir="$${dir}/target/coverage"; \
	target_dir="$${dir}/target/debug/deps"; \
	if [ -f "$${output_dir}/index.js" ]; then \
    rm "$${output_dir}/index.js"; \
	fi; \
	i=0; \
	for file in $$(ls $$target_dir/$(PACKAGE)-* | grep -v '\.d$$'); do \
	  kcov --verify --include-path=$$dir/src $$output_dir-$$i $$file; \
	done; \
	kcov --merge $$output_dir-$\* ; \
	grep 'index.html' $$output_dir-0/index.js* | \
	  grep -oE 'covered":"([0-9]*\.[0-9]*|[0-9]*)"' | \
	  grep -oE '[0-9]*\.[0-9]*|[0-9]*'
.PHONY: coverage

cov: | coverage
.PHONY: cov

# build
build\:debug:  ## Build in debug mode [alias: build]
	cargo build
.PHONY: build\:debug

build: | build\:debug
.PHONY: build

build\:release:  ## Create release build
	cargo build --release
.PHONY: build\:release

# utility
clean:  ## Clean up
	@cargo clean
.PHONY: clean

runner-%:  ## Run a CI job on local (on Docker)
	@set -uo pipefail; \
	job=$(subst runner-,,$@); \
	opt=""; \
	while read line; do \
	  opt+=" --env $$(echo $$line | sed -E 's/^export //')"; \
	done < .env.ci; \
	gitlab-runner exec docker \
	  --executor docker \
	  --cache-dir /cache \
	  --docker-volumes $$(pwd)/.cache/gitlab-runner:/cache \
	  --docker-volumes /var/run/docker.sock:/var/run/docker.sock \
	  $${opt} $${job}
.PHONY: runner

package:  ## Create package
	@cargo package
.PHONY: package

publish:  ## Publish package
	@cargo publish
.PHONY: publish

help:  ## Display this message
	@set -uo pipefail; \
	grep --extended-regexp '^[0-9a-z\%\:\\\-]+:  ## ' $(firstword $(MAKEFILE_LIST)) | \
	  sed --expression='s/\(\s|\(\s[0-9a-z\:\-\%\]*\)*\)  /  /' | \
	  tr --delete \\\\ | \
	  awk 'BEGIN {FS = ":  ## "};  \
	    {printf "\033[38;05;222m%-14s\033[0m %s\n", $$1, $$2}' | \
	  sort
.PHONY: help

.DEFAULT_GOAL = test:all
default: verify\:check verify\:format verify\:lint test\:all
