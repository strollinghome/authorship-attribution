// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAuthorshipAttribution {
    event AuthorshipAttribution(
        string name,
        string symbol,
        bytes32 salt,
        address token,
        address verifyingContract,
        string domainName,
        string version,
        address author,
        bytes signature
    );
}
