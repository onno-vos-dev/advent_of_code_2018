# rebar variables
REBAR_CONFIG := rebar.config
APP_VERSION := $(shell erl -eval \
	"{ok, [{application, advent_of_code, Info}]} =\
		file:consult(\"$(PWD)/apps/advent_of_code/src/advent_of_code.app.src\"),\
	io:fwrite(proplists:get_value(vsn, Info)), halt()." -noshell)
CLUSTER := $(CLUSTER)
DOCKER_TAG := $(VERSION)-$(CLUSTER)
BUILD_DIR := _build
RELEASE_TARBALL := $(BUILD_DIR)/$(CLUSTER)/rel/advent_of_code/advent_of_code-$(VERSION).tar.gz
ELVIS := _build/elvis/lib/elvis/_build/default/bin/elvis

##################
# advent_of_code make targets
##################
.PHONY: all
all: compile elvis test check

.PHONY: compile
compile:
	rebar3 compile

.PHONY: doc
doc:
	rebar3 edoc

.PHONY: check
check: xref dialyzer

.PHONY: dialyzer
dialyzer:
	rebar3 dialyzer

.PHONY: xref
xref:
	rebar3 xref

.PHONY: test
test: eunit ct

.PHONY: eunit
eunit:
	rebar3 eunit

.PHONY: ct
ct:
	rebar3 ct

.PHONY: clean
clean:
	rebar3 clean
	rm -f rebar.lock
	rm -rf $(BUILD_DIR)

.PHONY: release
release: $(RELEASE_TARBALL)

$(RELEASE_TARBALL): UID=$(shell id -u)
$(RELEASE_TARBALL):
	rebar3 clean
	rebar3 as prod tar

.PHONY: elvis
elvis: $(ELVIS)
	$(ELVIS) rock

$(ELVIS):
	rebar3 as elvis compile
	cd _build/elvis/lib/elvis && rebar3 escriptize
