# Authorship Attribution

Reference implementation for NFT Authorship Attribution. From the draft-EIP:

> ## Abstract
>
> This Ethereum Improvement Proposal (EIP) aims to solve the issue of authorship misattribution for ERC-721 Non-Fungible Tokens (NFT). To achieve this, this EIP proposes a mechanism where the NFT author signs the required parameters for the NFT creation, including the NFT metadata and a hash of any other relevant information. The signed parameters and the signature are then validated and emitted during the deployment transaction, which allows the contract to validate the authorship and NFT platforms to attribute authorship correctly. This method ensures that even if a different wallet sends the deployment transaction, the correct authorship is attributed to the actual author.
>
> ## Motivation
>
> Current NFT platforms assume that the wallet deploying the smart contract is the author of the NFT, leading to a misattribution of authorship in cases where a different wallet sends the deployment transaction. This proposal aims to solve the problem by allowing authors to sign the parameters required for NFT creation so that any wallet can send the deployment transaction without misattributing authorship.

This repo implements Authorship Attribution with two different deployment types for NFTs:

- Using a factory contract that deploys clones (using EIP-1167)
- Using an EOA to deploy the contract directly

The first type is implemented with `TokenFactory.sol` and `TokenClone.sol`, and the second type is `Token.sol`.

To run all tests, install foundry and run:

```
forge test
```
