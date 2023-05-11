// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IAuthorshipAttribution.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/access/AccessControl.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";

contract Token is IAuthorshipAttribution, EIP712, ERC721, AccessControl {
    bytes32 public constant TYPEHASH =
        keccak256(
            "AuthorshipAttribution(string name,string symbol,bytes32 salt,address author)"
        );

    constructor(
        string memory name_,
        string memory symbol_,
        bytes32 salt,
        address author,
        bytes memory signature
    ) EIP712("Token", "1") ERC721(name_, symbol_) {
        require(
            isValid(name_, symbol_, salt, address(this), author, signature),
            "invalid signature"
        );

        _grantRole(DEFAULT_ADMIN_ROLE, author);

        emit AuthorshipAttribution(
            name_,
            symbol_,
            salt,
            address(this),
            msg.sender,
            "TokenFactory",
            "1",
            author,
            signature
        );
    }

    function mint(address receiver) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(receiver, 1);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, AccessControl) returns (bool) {
        return
            ERC721.supportsInterface(interfaceId) ||
            AccessControl.supportsInterface(interfaceId);
    }

    function isValid(
        string memory name,
        string memory symbol,
        bytes32 salt,
        address token,
        address author,
        bytes memory signature
    ) public view returns (bool) {
        // TODO: Add ERC-1271 support.
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
