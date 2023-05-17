// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TokenClone.sol";
import "openzeppelin-contracts/contracts/proxy/Clones.sol";

contract TokenFactory {
    error Already_Deployed();

    address public immutable tokenImplementation;

    constructor() {
        tokenImplementation = address(new TokenClone());
    }

    function createToken(
        string memory name,
        string memory symbol,
        bytes32 salt,
        address author,
        address tokenAddress,
        bytes memory signature
    ) public returns (address) {
        if (tokenAddress.code.length > 0) revert Already_Deployed();

        address token = Clones.cloneDeterministic(
            tokenImplementation,
            keccak256(abi.encode(name, symbol, salt, author))
        );

        TokenClone(token).initialize(name, symbol, salt, author, signature);

        return token;
    }

    function predictDeterministicAddress(
        string memory name,
        string memory symbol,
        bytes32 salt,
        address author
    ) public view returns (address) {
        return
            Clones.predictDeterministicAddress(
                tokenImplementation,
                keccak256(abi.encode(name, symbol, salt, author)),
                address(this)
            );
    }
}
