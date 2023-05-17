// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import "../src/TokenFactory.sol";
import "../src/IAuthorshipAttribution.sol";

contract TokenFactoryTest is Test, IAuthorshipAttribution {
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
        bytes32 digest = _getDigest(name, symbol, salt, tokenAddress);

        // Sign salt (privateKey, digest) => (v, r, s).
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(authorPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        // Deploy token.
        vm.expectEmit(true, true, true, true, tokenAddress);
        emit AuthorshipAttribution(name, symbol, salt, "Token", "1", signature);
        TokenClone token = TokenClone(
            factory.createToken(
                name,
                symbol,
                salt,
                author,
                tokenAddress,
                signature
            )
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
        vm.expectRevert(0xb28989ee);
        factory.createToken(
            name,
            symbol,
            salt,
            author,
            tokenAddress,
            signature
        );
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
            "AuthorshipAttribution(string name,string symbol,bytes32 salt,address token)"
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
