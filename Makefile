PACKAGE = hype
BINARY = hype

# verify
verify\:check: ## Verify code syntax [alias: check]
	@cargo check --all --verbose
.PHONY: verify\:check

check: verify\:check
.PHONY: check

verify\:format: ## Verify format without changes [alias: verify:fmt, format, fmt]
	@cargo fmt --all -- --check
.PHONY: verify\:format

format: verify\:format
.PHONY: format

fmt: verify\:format
.PHONY: fmt

verify\:lint: ## Verify coding style using clippy [alias: lint]
	@cargo clippy --all-targets
.PHONY: verify\:lint

lint: verify\:lint
.PHONY: lint

verify\:all: verify\:check verify\:format verify\:lint ## Check code using all verify targets
.PHONY: verify\:all

verify: verify\:check ## Synonym for verify:check
.PHONY: verify

# test
test\:all: ## Run all unit tests
	@cargo test --tests
.PHONY: test\:all

test: test\:all ## Synonym for test:all
.PHONY: test

# coverage
coverage\:bin: ## Generate a coverage report of tests for binary [alias: cov:bin]
	@set -uo pipefail; \
	dir="$$(pwd)"; \
	target_dir="$${dir}/target/coverage/bin"; \
	cargo test --bin $(BINARY) --no-run --target-dir=$${target_dir}; \
	result=($${target_dir}/index.js*); \
	if [ -f $${result}[0] ]; then \
		rm "$${target_dir}/index.js*"; \
	fi; \
	file=($$target_dir/debug/deps/$(BINARY)-*); \
	kcov --verify --include-path=$$dir/src $$target_dir $${file[0]}; \
	grep 'index.html' $$target_dir/index.js* | \
		grep --only-matching --extended-regexp \
		'covered":"([0-9]*\.[0-9]*|[0-9]*)"' | sed -E 's/[a-z\:"]*//g'
.PHONY: coverage\:bin

cov\:bin: coverage\:bin
.PHONY: cov\:bin

coverage: coverage\:bin ## Same as coverage:bin [alias: cov]
.PHONY: coverage

cov: coverage
.PHONY: cov

# documentation
document: ## Generate documentation files [alias: doc]
	cargo rustdoc --package $(PACKAGE)
.PHONY: document

doc: document
.PHONY: doc

# build
build\:debug: ## Build in debug mode [alias: build]
	cargo build
.PHONY: build\:debug

build: build\:debug
.PHONY: build

build\:release: ## Create release build
	cargo build --release
.PHONY: build\:release

# utility
clean: ## Clean up
	@cargo clean
.PHONY: clean

runner-%: ## Run a CI job on local (on Docker)
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

package: ## Create package
	@cargo package
.PHONY: package

publish: ## Publish package
	@cargo publish
.PHONY: publish

help: ## Display this message
	@set -uo pipefail; \
	grep --extended-regexp '^[-_0-9a-z\%\:\\ ]+: ' \
		$(firstword $(MAKEFILE_LIST)) | \
		grep --extended-regexp ' ## ' | \
		sed --expression='s/\( [-_0-9a-z\%\:\\ ]*\) #/ #/' | \
		tr --delete \\\\ | \
		awk 'BEGIN {FS = ": ## "}; \
			{printf "\033[38;05;222m%-14s\033[0m %s\n", $$1, $$2}' | \
		sort
.PHONY: help

.DEFAULT_GOAL = test:all
default: verify\:check verify\:format verify\:lint test\:all
