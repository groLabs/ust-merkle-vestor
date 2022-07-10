// SPDX-License-Identifier: AGPLv3
pragma solidity 0.8.10;

import { console2 } from 'forge-std/console2.sol';
import { Test } from 'forge-std/Test.sol';
import { GMerkleVestor } from 'src/GMerkleVestor.sol';
import { MockERC20 } from 'src/Mocks/MockERC20.sol';

// merkle data for testing
// "root": "0x3d716f83ed930b6b542e68b462bb31ab21c4c52810d9a784e6c92f93bf6d7063"
//{
//   "address": "0x022Ce4715b44EF6F0eAd8561B29dA676928D16f3",
//    "amount": "74221418360000000000",
//    "proofs": [
//      "0xf4af01c1cb283bdb99c03e8e21e4d5302449578c64fcedad0265440b2c4f7a30",
//      "0x2ec282603082d52f0b627ddf7f1171c5b14fcfa10268cfae06e8602ec6e71c47",
//      "0xf9590d8d50cceec5eb97532e1d6c3b3bee5f8569c5417dd86750d3f44b4187ed",
//      "0xe4c39decedce6e55b2f9fef6ed6890bba72706f6e4a632e09ee016075f79c907",
//      "0xf56a479881743dfce47a7d142179ad89df8d29e0404e9dcc36433ad2353ac28f",
//      "0x26b733621d7e371e99c97e9f5676af8157adcf9da6875924e1bf22691b94792b",
//      "0x785969f19edd48af29a9ec6f3d7d6b6302d45d50f9df2de7ba0e83d8b5ca1aab",
//      "0xccc2ae174e184922bfddef5bdfa73dd71f82a6183ebf261fd673b46f0e5f9e75"
//    ]
//  }

contract User {

}

contract GMerkleVestorTest is Test {
	User internal user;
	MockERC20 internal token;
	GMerkleVestor internal gmerkle;
	uint256 internal testTimestamp;
	uint256 internal userTotalClaim;
	bytes32[] internal proof;
	address internal user2;

	function setUp() public {
		// deploy contracts
		token = new MockERC20();
		user = new User();
		gmerkle = new GMerkleVestor(
			address(token),
			1654811402,
			0x3d716f83ed930b6b542e68b462bb31ab21c4c52810d9a784e6c92f93bf6d7063
		);

		// setup common variables
		user2 = address(0x022Ce4715b44EF6F0eAd8561B29dA676928D16f3);
		testTimestamp = 1657406456;
		proof = [
			bytes32(0xf4af01c1cb283bdb99c03e8e21e4d5302449578c64fcedad0265440b2c4f7a30),
			0x2ec282603082d52f0b627ddf7f1171c5b14fcfa10268cfae06e8602ec6e71c47,
			0xf9590d8d50cceec5eb97532e1d6c3b3bee5f8569c5417dd86750d3f44b4187ed,
			0xe4c39decedce6e55b2f9fef6ed6890bba72706f6e4a632e09ee016075f79c907,
			0xf56a479881743dfce47a7d142179ad89df8d29e0404e9dcc36433ad2353ac28f,
			0x26b733621d7e371e99c97e9f5676af8157adcf9da6875924e1bf22691b94792b,
			0x785969f19edd48af29a9ec6f3d7d6b6302d45d50f9df2de7ba0e83d8b5ca1aab,
			0xccc2ae174e184922bfddef5bdfa73dd71f82a6183ebf261fd673b46f0e5f9e75
		];
		userTotalClaim = 74221418360000000000;

		// Get MockERC20 and transfer to GMerkleVestor
		vm.startPrank(address(user));
		token.faucet();
		token.transfer(address(gmerkle), 1E23);
		vm.stopPrank();
	}

	function testCanClaimMerkleDrop() public {
		vm.startPrank(user2);
		bool canClaim = gmerkle.canClaim(proof, userTotalClaim);
		assertEq(canClaim, true);
		vm.stopPrank();
	}

	function testCanSeeVestedAmount() public {
		vm.warp(testTimestamp);
		vm.startPrank(user2);
		uint256 vestedAmount = gmerkle.getVestedAmount(proof, userTotalClaim);
		assertGt(vestedAmount, 0);
		vm.stopPrank();
	}

	function testCanDoInitialClaim() public {
		vm.warp(testTimestamp);
		vm.startPrank(user2);
		gmerkle.initialClaim(proof, userTotalClaim);
		uint256 userTokenBalance = token.balanceOf(user2);
		assertGt(userTokenBalance, 0);
		vm.stopPrank();
	}

	function testUserCannotDoInitialClaimTwice() public {
		vm.warp(testTimestamp);
		vm.startPrank(user2);
		gmerkle.initialClaim(proof, userTotalClaim);
		uint256 userTokenBalance = token.balanceOf(user2);
		assertGt(userTokenBalance, 0);
		vm.expectRevert(bytes('initialClaim: already initially claimed'));
		gmerkle.initialClaim(proof, userTotalClaim);
		vm.stopPrank();
	}

	function testUserCannotCallClaimWithoutInitialClaimFirst() public {
		vm.warp(testTimestamp);
		vm.startPrank(user2);
		vm.expectRevert(bytes('claim: claim not started'));
		gmerkle.claim();
		vm.stopPrank();
	}

	function testUserCanClaimFullAmountOnInitialClaim() public {
		uint256 endTimestamp = gmerkle.vestingEndTime();
		vm.warp(endTimestamp);
		vm.startPrank(user2);
		gmerkle.initialClaim(proof, userTotalClaim);
		uint256 userTokenBalance = token.balanceOf(user2);
		assertEq(userTokenBalance, userTotalClaim);
		vm.stopPrank();
	}

	function testUserCanClaimInitialAmountAndOnGoingClaim() public {}

	function testOwnerCanSweepToken() public {}

	function testOnlyOwnerCanSweepToken() public {}
}