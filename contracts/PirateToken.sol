// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PirateToken is ERC20 {
    // declaring the initial supply of the token
    // e18 to factor in the decimal places
    uint256 initialSupply = 10000e18;

    constructor() ERC20("Pirate", "PRT") {
        _mint(msg.sender, initialSupply);
    }
}
