// SPDX-License-Identifier: AGPLv3
pragma solidity 0.8.10;

import { Script } from 'forge-std/Script.sol';
import { GMerkleVestor } from '../src/GMerkleVestor.sol';

contract DeploymentScript is Script {
	function run() external {
		vm.startBroadcast();
		// constructor values for gMerkleVestor
		address token = address(0xF0a93d4994B3d98Fb5e3A2F90dBc2d69073Cb86b);
		uint256 vestingStartTime = 1656654244;
		bytes32 merkleRoot = bytes32(0x391ebf4ec9c9c71a62b053ebe97de660302989c7b7e0921d4f548c8b6f425a7c);
        // deploy contract
		GMerkleVestor gMerkleVestor = new GMerkleVestor(token, vestingStartTime, merkleRoot);
        // transfer ownership to the DAO Multisig
        address daoMultiSig = address(0x359F4fe841f246a095a82cb26F5819E10a91fe0d);
        gMerkleVestor.transferOwnership(daoMultiSig);

		vm.stopBroadcast();
	}
}
