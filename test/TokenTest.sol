// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/TokenFactory.sol";

contract TokenTest is Test {
    TokenFactory public factory;

    uint256 authorPrivateKey = 12345;
    address author = vm.addr(authorPrivateKey);

    string name = "Test Token";
    string symbol = "TTT";
    bytes32 salt = bytes32(0);

    function setUp() public {
        factory = new TokenFactory();
    }

    function testDeploy() public {
        // Get expected token address.
        address tokenAddress = factory.predictDeterministicAddress(
            name,
            symbol,
            salt,
            author
        );

        // Get digest.
        bytes32 digest = factory.getDigest(name, symbol, salt, tokenAddress);

        // Sign salt (privateKey, digest) => (v, r, s).
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(authorPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        // Deploy token.
        Token token = Token(
            factory.createToken(name, symbol, salt, author, signature)
        );

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

        // Expect revert since the params have already been used.
        vm.expectRevert("Initializable: contract is already initialized");
        token.initialize(name, symbol, salt, author, signature);

        // Expect revert since the params have already been used.
        vm.expectRevert("ERC1167: create2 failed");
        factory.createToken(name, symbol, salt, author, signature);
    }
}
