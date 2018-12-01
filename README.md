# Advent of Code 2018

## Getting Started

1. git clone
2. `make`
3. `./rebar shell` to start an erlang shell with all applications loaded

### Prerequisites

OTP 19.1

## Running the tests

To run the tests, simply execute `make test` which runs eunit and common tests.

### And coding style tests

This repo is using [elvis](https://github.com/inaka/elvis) to enforce coding style guidelines. Configuration is defined in `elvis.config` and can be tweaked that way. Furthermore both XREF and Dialyzer can be run using `make xref` and `make dialyzer`. To run both simply execute `make check`

## Authors
Onno Vos
