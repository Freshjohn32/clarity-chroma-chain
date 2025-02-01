# ChromaChain

A dynamic NFT platform for generative art collections built on Stacks blockchain.

## Features
- Mint dynamic NFTs with procedurally generated artwork
- Update NFT attributes and metadata
- Royalty system for creators
- Built-in marketplace functionality
- On-chain attribute generation
- Batch operations for efficient large collection management
  - Batch mint up to 50 NFTs in a single transaction
  - Batch list multiple NFTs with the same price
  - Gas-optimized operations for large collections

## Getting Started
1. Install Clarinet
2. Clone the repository
3. Run `clarinet console` to interact with contracts
4. Run tests with `clarinet test`

## Batch Operations
To mint multiple NFTs in a single transaction:
```clarity
(contract-call? .chroma-nft batch-mint u10 "Collection #" "Description" "ipfs://base/" attributes)
```

To list multiple NFTs at once:
```clarity
(contract-call? .chroma-nft batch-list (list u1 u2 u3 u4 u5) u1000)
```
