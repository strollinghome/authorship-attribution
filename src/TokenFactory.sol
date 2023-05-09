// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Token.sol";
import "openzeppelin-contracts/contracts/proxy/Clones.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";

contract TokenFactory is EIP712 {
    address public immutable tokenImplementation;

    bytes32 public constant TYPEHASH =
        keccak256(
            "AuthorshipAttribution(string name,string symbol,bytes32 salt,address author)"
        );

    constructor() EIP712("TokenFactory", "1") {
        tokenImplementation = address(new Token());
    }

    function createToken(
        string memory name,
        string memory symbol,
        bytes32 salt,
        address author,
        bytes memory signature
    ) public returns (address) {
        address tokenAddress = predictDeterministicAddress(
            name,
            symbol,
            salt,
            author
        );

        require(
            isValid(name, symbol, salt, tokenAddress, author, signature),
            "invalid signature"
        );

        address token = Clones.cloneDeterministic(
            tokenImplementation,
            keccak256(abi.encode(name, symbol, salt, author))
        );

        Token(token).initialize(name, symbol, salt, author, signature);

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

    function isValid(
        string memory name,
        string memory symbol,
        bytes32 salt,
        address token,
        address author,
        bytes memory signature
    ) public view returns (bool) {
        bytes32 digest = getDigest(name, symbol, salt, token);

        return
            author != address(0) && ECDSA.recover(digest, signature) == author;
    }

    function getDigest(
        string memory name,
        string memory symbol,
        bytes32 salt,
        address token
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(abi.encode(TYPEHASH, name, symbol, salt, token))
            );
    }
}
