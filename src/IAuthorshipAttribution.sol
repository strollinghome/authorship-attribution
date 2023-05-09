// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAuthorshipAttribution {
    event AuthorshipAttribution(
        string name,
        string symbol,
        bytes salt,
        address token,
        address verifyingContract,
        string domainName,
        string version,
        address author,
        bytes signature
    );
}
