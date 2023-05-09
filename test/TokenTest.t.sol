// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/Token.sol";

contract TokenTest is Test {
    uint256 authorPrivateKey = 12345;
    address author = vm.addr(authorPrivateKey);

    string name = "Test Token";
    string symbol = "TTT";
    bytes32 salt = bytes32(0);

    function testDeploy() public {
        address deployer = vm.addr(2468);

        // Get expected token address.
        address tokenAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xd6),
                            bytes1(0x94),
                            deployer,
                            bytes1(0x80)
                        )
                    )
                )
            )
        );

        // Get digest.
        bytes32 digest = _getDigest(name, symbol, salt, tokenAddress);

        // Sign salt (privateKey, digest) => (v, r, s).
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(authorPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        // Deploy token.
        vm.prank(deployer);
        Token token = new Token(name, symbol, salt, author, signature);

        // Check token metadata.
        assertEq(tokenAddress, address(token));
        assertEq(token.name(), name);
        assertEq(token.symbol(), symbol);
        assertTrue(token.hasRole(token.DEFAULT_ADMIN_ROLE(), author));

        // Mint token.
        address receiver = vm.addr(54321);
        vm.prank(author);
        token.mint(receiver);
        assertEq(token.ownerOf(1), receiver);
    }

    function _getDigest(
        string memory _name,
        string memory _symbol,
        bytes32 _salt,
        address tokenAddress
    ) internal view returns (bytes32) {
        bytes32 EIP712_TYPEHASH = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        bytes32 nameHash = keccak256(bytes("Token"));
        bytes32 versionHash = keccak256(bytes("1"));

        bytes32 TYPEHASH = keccak256(
            "AuthorshipAttribution(string name,string symbol,bytes32 salt,address author)"
        );

        return
            ECDSA.toTypedDataHash(
                _buildDomainSeparator(
                    EIP712_TYPEHASH,
                    nameHash,
                    versionHash,
                    tokenAddress
                ),
                keccak256(
                    abi.encode(TYPEHASH, _name, _symbol, _salt, tokenAddress)
                )
            );
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash,
        address verifyingContract
    ) private view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    typeHash,
                    nameHash,
                    versionHash,
                    block.chainid,
                    verifyingContract
                )
            );
    }
}
