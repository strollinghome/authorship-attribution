// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IAuthorshipAttribution.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";

contract TokenClone is
    IAuthorshipAttribution,
    ERC721Upgradeable,
    AccessControlUpgradeable
{
    function initialize(
        string memory name_,
        string memory symbol_,
        bytes32 salt,
        address author,
        bytes memory signature
    ) public reinitializer(1) {
        __ERC721_init_unchained(name_, symbol_);

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
}
