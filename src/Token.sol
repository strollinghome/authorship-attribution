// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IAuthorshipAttribution.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC721/ERC721Upgradeable.sol";

contract Token is IAuthorshipAttribution, ERC721Upgradeable {
    function initialize(
        string memory name_,
        string memory symbol_,
        bytes32 salt,
        address author,
        bytes memory signature
    ) public reinitializer(1) {
        __ERC721_init_unchained(name_, symbol_);

        emit AuthorshipAttribution(
            name_, // name
            symbol_, // symbol
            salt, // salt
            address(this), // token
            msg.sender, // verifyingContract
            "example.com", // domainName
            "1", // version
            author, // author
            signature // signature
        );
    }
}
