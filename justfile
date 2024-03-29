#!/usr/bin/env just --justfile

bt := '0'

export RUST_BACKTRACE := bt

log := "warn"

export JUST_LOG := log

_default:
  just --list

# load .env file
set dotenv-load

# pass recipe args as positional arguments to commands
set positional-arguments

## ---- Environment ----

HEX_18 := "0x0000000000000000000000000000000000000000000000000000000000000012"
HEX_12 := "0x000000000000000000000000000000000000000000000000000000000000000c"
HEX_8  := "0x0000000000000000000000000000000000000000000000000000000000000008"
HEX_6  := "0x0000000000000000000000000000000000000000000000000000000000000006"

# set mock target to 18 decimals by default
FORGE_MOCK_TARGET_DECIMALS := env_var_or_default("FORGE_MOCK_TARGET_DECIMALS", HEX_18)
FORGE_MOCK_UNDERLYING_DECIMALS := env_var_or_default("FORGE_MOCK_UNDERLYING_DECIMALS", HEX_18)

DAPP_BUILD_OPTIMIZE := "1"
DAPP_COVERAGE       := "1"
# when developing we only want to fuzz briefly
DAPP_TEST_FUZZ_RUNS := "100"

ALCHEMY_KEY := env_var("ALCHEMY_KEY")
MAINNET_RPC := "https://eth-mainnet.alchemyapi.io/v2/" + ALCHEMY_KEY
MNEMONIC    := env_var("MNEMONIC")

# export just vars as env vars
set export


size:
	forge build --sizes --force


# build using forge
build: && _timer
	cd {{ invocation_directory() }}; forge build


# default test scripts
test: test-local

# run local forge test using --match <PATTERN>

test-local *commands="": && _timer
	cd {{ invocation_directory() }}; forge test -m ".t.sol" {{ commands }}

# run mainnet fork forge tests (all files with the extension .debug.sol)
test-mainnet *commands="": && _timer
	cd {{ invocation_directory() }}; forge test --rpc-url {{ MAINNET_RPC }} -m ".debug.sol" {{ commands }}


gas-snapshot: gas-snapshot-local

# get gas snapshot from local tests and save it to file
gas-snapshot-local:
    cd {{ invocation_directory() }}; \
    just test-local | grep 'gas:' | cut -d " " -f 2-4 | sort > \
    {{ justfile_directory() }}/gas-snapshots/.$( \
        cat {{ invocation_directory() }}/package.json | jq .name | tr -d '"' | cut -d"/" -f2- \
    )

forge-gas-snapshot: && _timer
	@cd {{ invocation_directory() }}; forge snapshot --no-match-path ".*t.*"

forge-gas-snapshot-diff: && _timer
	@cd {{ invocation_directory() }}; forge snapshot --no-match-path ".*t.*" --diff



# utility functions
start_time := `date +%s`
_timer:
    @echo "Task executed in $(($(date +%s) - {{ start_time }})) seconds"

# Solidity test ffi callback to get Target decimals for the base Mock Target token
_forge_mock_target_decimals:
    @printf {{ FORGE_MOCK_TARGET_DECIMALS }}

_forge_mock_underlying_decimals:
    @printf {{ FORGE_MOCK_UNDERLYING_DECIMALS }}
