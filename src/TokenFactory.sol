// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Token.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/ClonesUpgradeable.sol";

contract TokenFactory {
    address public immutable tokenImplementation;

    constructor() {
        tokenImplementation = address(new Token());
    }

    function createToken(
        string memory name,
        string memory symbol
    ) public returns (address) {
        address token = ClonesUpgradeable.clone(tokenImplementation);
        // Token(token).initialize(name, symbol);
        return token;
    }
}
