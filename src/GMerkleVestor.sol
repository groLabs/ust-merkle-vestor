// SPDX-License-Identifier: AGPLv3
pragma solidity 0.8.10;

import { IERC20 } from 'openzeppelin-contracts/contracts/token/ERC20/IERC20.sol';
import { MerkleProof } from 'openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol';
import { Ownable } from 'openzeppelin-contracts/contracts/access/Ownable.sol';
import { SafeERC20 } from 'openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol';

contract GMerkleVestor is Ownable {
	using SafeERC20 for IERC20;

	struct UserInfo {
		uint256 totalClaim;
		uint256 claimedAmount;
	}

	uint256 internal constant ONE_MONTH_SECONDS = 2592000; //60 * 60 * 24 * 30 (30 day months)
	uint256 internal constant VESTING_TIME = ONE_MONTH_SECONDS * 23; // 2 years period - 1 month

	address public immutable token;
	uint256 public immutable vestingStartTime;
	uint256 public immutable vestingEndTime;
	bytes32 immutable merkleRoot;
	mapping(address => bool) claimStarted;
	mapping(address => UserInfo) usersInfo;

	constructor(
		address _token,
		uint256 _vetingStartTime,
		bytes32 _merkleRoot
	) {
		token = _token;
		vestingStartTime = _vetingStartTime;
		merkleRoot = _merkleRoot;
		vestingEndTime = _vetingStartTime + VESTING_TIME;
	}

	// TODO write natspec this is for user to check if they part of merkle tree
	function canClaim(bytes32[] memory proof, uint256 amount) external view returns (bool) {
		// create leaf with user address and amount
		bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
		// verify valid proof
		return MerkleProof.verify(proof, merkleRoot, leaf);
	}

	// TODO write natspec, this is a helper func for users to check how much they can currently claim
	function getVestedAmount(bytes32[] memory proof, uint256 _totalClaim)
		external
		view
		returns (uint256)
	{
		uint256 currentClaimableAmount;
		// If user hasn't started a claim yet calculate vested amount
		if (!claimStarted[msg.sender]) {
			// create leaf with user address and amount
			bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _totalClaim));
			// verify valid proof
			require(MerkleProof.verify(proof, merkleRoot, leaf), 'getVestedAmount: Invalid Proof');

			// calculate how much user has vested that we can send on this inital claim
			if (block.timestamp < vestingEndTime) {
				currentClaimableAmount =
					(_totalClaim * (block.timestamp - vestingStartTime)) /
					(VESTING_TIME);
			} else {
				currentClaimableAmount = _totalClaim;
			}

			return currentClaimableAmount;
		}

		// calculate how much user has vested accounting for claims already made
		UserInfo memory currentPosition = usersInfo[msg.sender];

		if (block.timestamp < vestingEndTime) {
			currentClaimableAmount =
				((currentPosition.totalClaim * (block.timestamp - vestingStartTime)) /
					(VESTING_TIME)) -
				currentPosition.claimedAmount;
		} else {
			currentClaimableAmount = currentPosition.totalClaim - currentPosition.claimedAmount;
		}

		return currentClaimableAmount;
	}

	// TODO Write natspec this is to setup a users position and first claim
	function initialClaim(bytes32[] memory proof, uint256 amount) external {
		// create leaf with user address and amount
		bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
		// verify valid proof
		require(MerkleProof.verify(proof, merkleRoot, leaf), 'initialClaim: Invalid Proof');

		// ensure user hasn't claimed already
		require(!claimStarted[msg.sender], 'initialClaim: already initially claimed');

		// verify claim started for user
		claimStarted[msg.sender] = true;

		// calculate how much user has vested that we can send on this inital claim
		uint256 currentClaimableAmount;

		if (block.timestamp < vestingEndTime) {
			currentClaimableAmount =
				(amount * (block.timestamp - vestingStartTime)) /
				(VESTING_TIME);
		} else {
			currentClaimableAmount = amount;
		}

		// update usersInfo mapping
		UserInfo memory newUser = UserInfo(amount, currentClaimableAmount);
		usersInfo[msg.sender] = newUser;

		// transfer funds to user
		IERC20(token).safeTransfer(msg.sender, currentClaimableAmount);
	}

	// TODO natspec later but this suppoed to be cheaper alternative once position started
	function claim() external {
		require(claimStarted[msg.sender] = true, 'claim: claim not started');

		// calculate how much user has vested that we can send on this inital claim
		uint256 currentClaimableAmount;
		UserInfo memory currentPosition = usersInfo[msg.sender];

		if (block.timestamp < vestingEndTime) {
			currentClaimableAmount =
				((currentPosition.totalClaim * (block.timestamp - vestingStartTime)) /
					(VESTING_TIME)) -
				currentPosition.claimedAmount;
		} else {
			currentClaimableAmount = currentPosition.totalClaim - currentPosition.claimedAmount;
		}

		// update claimed amount for user in storage
		usersInfo[msg.sender].claimedAmount =
			currentPosition.claimedAmount +
			currentClaimableAmount;

		// transfer funds to user
		IERC20(token).safeTransfer(msg.sender, currentClaimableAmount);
	}

	function sweep(uint256 _amount) external onlyOwner {
		// transfer funds to user
		IERC20(token).safeTransfer(owner(), _amount);
	}
}
