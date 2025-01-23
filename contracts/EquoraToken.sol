// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EquoraToken is ERC20 {
    uint256 private constant TOTAL_SUPPLY = 8025000000 * 10 ** 18;

    constructor() ERC20("Equora", "EQR") {
        _mint(msg.sender, TOTAL_SUPPLY);
    }
}
