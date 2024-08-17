# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# Remove modules
remove:
	rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

# Install the Modules
install:
	forge install foundry-rs/forge-std --no-commit
	forge install Transient-Labs/tl-sol-tools@3.0.0 --no-commit

# Update the modules
update: remove install

#  Builds
clean:
	forge fmt && forge clean

build:
	forge build --evm-version paris

clean_build: clean build

# Tests
quick_test:
	forge test --fuzz-runs 256

std_test:
	forge test

gas_test:
	forge test --gas-report

fuzz_test:
	forge test --fuzz-runs 10000

coverage_test:
	forge coverage

# Deployments
deploy_arbitrum_sepolia: build
	forge script script/Deploy.s.sol:Deploy --evm-version paris --rpc-url arbitrum_sepolia --ledger --sender ${SENDER} --broadcast
	forge verify-contract $$(cat out.txt) src/TRACERSRegistry.sol:TRACERSRegistry --verifier-url https://api-sepolia.arbiscan.io/api --etherscan-api-key ${ARBISCAN_KEY} --watch --constructor-args ${CONSTRUCTOR_ARGS}
	@bash print_and_clean.sh

deploy_base_sepolia: build
	forge script script/Deploy.s.sol:Deploy --evm-version paris --rpc-url base_sepolia --ledger --sender ${SENDER} --broadcast
	forge verify-contract $$(cat out.txt) src/TRACERSRegistry.sol:TRACERSRegistry --chain base-sepolia --watch --constructor-args ${CONSTRUCTOR_ARGS}
	@bash print_and_clean.sh

deploy_shape_sepolia: build
	forge script script/Deploy.s.sol:Deploy --evm-version paris --rpc-url shape_sepolia --ledger --sender ${SENDER} --broadcast
	forge verify-contract $$(cat out.txt) src/TRACERSRegistry.sol:TRACERSRegistry --verifier blockscout --verifier-url https://explorer-sepolia.shape.network/api --watch --constructor-args ${CONSTRUCTOR_ARGS}
	@bash print_and_clean.sh

deploy_arbitrum_one: build
	forge script script/Deploy.s.sol:Deploy --evm-version paris --rpc-url arbitrum --ledger --sender ${SENDER} --broadcast
	forge verify-contract $$(cat out.txt) src/TRACERSRegistry.sol:TRACERSRegistry --chain arbitrum --watch --constructor-args ${CONSTRUCTOR_ARGS}
	@bash print_and_clean.sh

deploy_base: build
	forge script script/Deploy.s.sol:Deploy --evm-version paris --rpc-url base --ledger --sender ${SENDER} --broadcast
	forge verify-contract $$(cat out.txt) src/TRACERSRegistry.sol:TRACERSRegistry --chain base --watch --constructor-args ${CONSTRUCTOR_ARGS}
	@bash print_and_clean.sh