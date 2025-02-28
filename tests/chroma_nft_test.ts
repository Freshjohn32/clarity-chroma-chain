import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can batch mint multiple NFTs",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const attributes = types.list([
      types.tuple({
        'trait': types.utf8('background'),
        'value': types.utf8('blue')
      })
    ]);
    
    let block = chain.mineBlock([
      Tx.contractCall('chroma-nft', 'batch-mint', [
        types.uint(5),
        types.utf8('Test NFT'),
        types.utf8('A test NFT'),
        types.utf8('ipfs://test/'),
        attributes
      ], deployer.address)
    ]);
    
    block.receipts[0].result.expectOk();
    assertEquals(block.receipts[0].events.length, 5);
  }
});

Clarinet.test({
  name: "Cannot batch mint with empty attributes",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const attributes = types.list([]);
    
    let block = chain.mineBlock([
      Tx.contractCall('chroma-nft', 'batch-mint', [
        types.uint(5),
        types.utf8('Test NFT'),
        types.utf8('A test NFT'),
        types.utf8('ipfs://test/'),
        attributes
      ], deployer.address)
    ]);
    
    block.receipts[0].result.expectErr(106);
  }
});

Clarinet.test({
  name: "Can batch list multiple NFTs",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    let tokenIds = [];
    for(let i = 1; i <= 5; i++) {
      tokenIds.push(types.uint(i));
    }
    
    let block = chain.mineBlock([
      Tx.contractCall('chroma-nft', 'batch-list', [
        types.list(tokenIds),
        types.uint(1000)
      ], deployer.address)
    ]);
    
    block.receipts[0].result.expectOk();
  }
});

Clarinet.test({
  name: "Cannot batch list with zero price",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    let tokenIds = [types.uint(1)];
    
    let block = chain.mineBlock([
      Tx.contractCall('chroma-nft', 'batch-list', [
        types.list(tokenIds),
        types.uint(0)
      ], deployer.address)
    ]);
    
    block.receipts[0].result.expectErr(105);
  }
});
