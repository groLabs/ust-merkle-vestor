// SPDX-License-Identifier: AGPLv3
pragma solidity 0.8.10;

import { Script } from 'forge-std/Script.sol';
import { GMerkleVestor } from '../src/GMerkleVestor.sol';

contract DeploymentScript is Script {
	function run() external {
		vm.startBroadcast();
		// TODO update constructor values when deploying to mainnet
		address token = address(0);
		uint256 vestingStartTime = 0;
		bytes32 merkleRoot = bytes32(0);

		GMerkleVestor gMerkleVestor = new GMerkleVestor(token, vestingStartTime, merkleRoot);

		vm.stopBroadcast();
	}
}
