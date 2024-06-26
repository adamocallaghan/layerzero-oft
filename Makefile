-include .env

####################
# DEPLOY CONTRACTS #
####################

deploy-oft-to-sepolia:
	forge create src/OFT_Sepolia.sol:OFT_Sepolia --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY)

deploy-oft-to-mumbai:
	forge create src/OFT_Mumbai.sol:OFT_Mumbai --rpc-url $(MUMBAI_RPC_URL) --private-key $(PRIVATE_KEY)

####################
# VERIFY CONTRACTS #
####################

verify-deployed-contract-on-sepolia:
	forge verify-contract --chain-id 11155111 --watch $(SEPOLIA_OFT_ADDRESS) src/OFT_Sepolia.sol:OFT_Sepolia --etherscan-api-key $(ETHERSCAN_KEY)

verify-deployed-contract-on-mumbai:
	forge verify-contract --chain-id 80001 --watch $(MUMBAI_OFT_ADDRESS) src/OFT_Mumbai.sol:OFT_Mumbai --etherscan-api-key $(POLYGONSCAN_KEY)

#######################################
# SET PEERS - aka 'wire up' contracts #
#######################################

set-peer-on-sepolia-contract:
	cast send $(SEPOLIA_OFT_ADDRESS) "setPeer(uint32,bytes32)" 40109 $(MUMBAI_BYTES32_PEER) --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY)

set-peer-on-mumbai-contract:
	cast send $(MUMBAI_OFT_ADDRESS) "setPeer(uint32,bytes32)" 40161 $(SEPOLIA_BYTES32_PEER) --rpc-url $(MUMBAI_RPC_URL) --private-key $(PRIVATE_KEY)

############################
# CHECK PEERS ARE WIRED UP #
############################

check-sepolia-peer:
	cast call $(SEPOLIA_OFT_ADDRESS) "isPeer(uint32,bytes32)(bool)" 40109 $(MUMBAI_BYTES32_PEER) --rpc-url $(SEPOLIA_RPC_URL)

check-mumbai-peer:
	cast call $(MUMBAI_OFT_ADDRESS) "isPeer(uint32,bytes32)(bool)" 40161 $(SEPOLIA_BYTES32_PEER) --rpc-url $(MUMBAI_RPC_URL)

########################
# CHECK TOTAL BALANCES #
########################

check-sepolia-total-supply:
	cast call $(SEPOLIA_OFT_ADDRESS) "totalSupply()(uint)" --rpc-url $(SEPOLIA_RPC_URL)

check-mumbai-total-supply:
	cast call $(MUMBAI_OFT_ADDRESS) "totalSupply()(uint)" --rpc-url $(MUMBAI_RPC_URL)

########################
# SET ENFORCED OPTIONS #
########################

set-enforced-options-on-sepolia-contract:
	cast send $(SEPOLIA_OFT_ADDRESS) "setEnforcedOptions((uint32,uint16,bytes)[])" "[(40109,1,0x00030100110100000000000000000000000000030d40)]" --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY)

########################################
# CALL quoteSend() TO GET GAS ESTIMATE #
########################################

get-send-quote-on-sepolia:
	cast call $(SEPOLIA_OFT_ADDRESS) "quoteSend((uint32,bytes32,uint256,uint256,bytes,bytes,bytes),bool)(uint,uint)" "(40109,$(MUMBAI_BYTES32_PEER),100000000000000,100000000000000,0x00030100110100000000000000000000000000030d40,0x,0x)" false --rpc-url $(SEPOLIA_RPC_URL)

get-send-quote-on-mumbai:
	cast call $(MUMBAI_OFT_ADDRESS) "quoteSend((uint32,bytes32,uint256,uint256,bytes,bytes,bytes),bool)(uint,uint)" "(40161,$(MUMBAI_BYTES32_PEER),100000000000000,100000000000000,0x00030100110100000000000000000000000000030d40,0x,0x)" false --rpc-url $(MUMBAI_RPC_URL)

###################
# SEND TOKENS !!! #
###################

send-tokens-from-sepolia-to-mumbai:
	cast send $(SEPOLIA_OFT_ADDRESS) "send((uint32,bytes32,uint256,uint256,bytes,bytes,bytes),(uint,uint),address)" "(40109,$(MUMBAI_BYTES32_PEER),10000000000000000000,10000000000000000000,0x,0x,0x)" "(10000000000000000,0)" $(PUBLIC_ADDRESS) --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --value 0.01ether