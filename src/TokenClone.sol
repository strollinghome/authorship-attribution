// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IAuthorshipAttribution.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";

contract TokenClone is
    EIP712,
    IAuthorshipAttribution,
    ERC721Upgradeable,
    AccessControlUpgradeable
{
    bytes32 public constant TYPEHASH =
        keccak256(
            "AuthorshipAttribution(string name,string symbol,bytes32 salt,address token)"
        );

    string private DOMAIN_NAME = "Token";
    string private VERSION = "1";

    constructor() EIP712(DOMAIN_NAME, VERSION) {}

    function initialize(
        string memory name_,
        string memory symbol_,
        bytes32 salt,
        address author,
        bytes memory signature
    ) public reinitializer(1) {
        require(
            isValid(name_, symbol_, salt, address(this), author, signature),
            "invalid signature"
        );

        __ERC721_init_unchained(name_, symbol_);

        _grantRole(DEFAULT_ADMIN_ROLE, author);

        emit AuthorshipAttribution(
            name_,
            symbol_,
            salt,
            DOMAIN_NAME,
            VERSION,
            signature
        );
    }

    function mint(address receiver) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(receiver, 1);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return
            ERC721Upgradeable.supportsInterface(interfaceId) ||
            AccessControlUpgradeable.supportsInterface(interfaceId);
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
