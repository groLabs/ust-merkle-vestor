// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import { ERC20 } from 'openzeppelin-contracts/contracts/token/ERC20/ERC20.sol';

contract MockERC20 is ERC20 {
	mapping(address => bool) internal claimed;

	constructor() ERC20('DAI', 'DAI') {}

	function faucet() external {
		require(!claimed[msg.sender], 'Already claimed');
		claimed[msg.sender] = true;
		_mint(msg.sender, 1E23);
	}

	function mint(address account, uint256 amount) external {
		require(account != address(0), 'Account is empty.');
		require(amount > 0, 'amount is less than zero.');
		_mint(account, amount);
	}

	function burn(address account, uint256 amount) external {
		require(account != address(0), 'Account is empty.');
		require(amount > 0, 'amount is less than zero.');
		_burn(account, amount);
	}
}
