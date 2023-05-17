// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAuthorshipAttribution {
    event AuthorshipAttribution(
        string name,
        string symbol,
        bytes32 salt,
        string domainName,
        string version,
        bytes signature
    );
}
