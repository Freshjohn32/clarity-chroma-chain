import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can mint a new NFT",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const attributes = types.list([
      types.tuple({
        'trait': types.utf8('background'),
        'value': types.utf8('blue')
      })
    ]);
    
    let block = chain.mineBlock([
      Tx.contractCall('chroma-nft', 'mint', [
        types.utf8('Test NFT'),
        types.utf8('A test NFT'),
        types.utf8('ipfs://test'),
        attributes
      ], deployer.address)
    ]);
    
    block.receipts[0].result.expectOk();
    assertEquals(block.receipts[0].result.expectOk(), types.uint(1));
  }
});

Clarinet.test({
  name: "Can update NFT metadata",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const attributes = types.list([
      types.tuple({
        'trait': types.utf8('background'),
        'value': types.utf8('red')
      })
    ]);
    
    let block = chain.mineBlock([
      Tx.contractCall('chroma-nft', 'mint', [
        types.utf8('Test NFT'),
        types.utf8('A test NFT'),
        types.utf8('ipfs://test'),
        attributes
      ], deployer.address),
      
      Tx.contractCall('chroma-nft', 'update-metadata', [
        types.uint(1),
        types.utf8('Updated NFT'),
        types.utf8('Updated description'),
        types.utf8('ipfs://updated'),
        attributes
      ], deployer.address)
    ]);
    
    block.receipts[0].result.expectOk();
    block.receipts[1].result.expectOk();
  }
});

Clarinet.test({
  name: "Can list and purchase NFT",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const buyer = accounts.get('wallet_1')!;
    const attributes = types.list([]);
    
    let block = chain.mineBlock([
      Tx.contractCall('chroma-nft', 'mint', [
        types.utf8('Test NFT'),
        types.utf8('A test NFT'),
        types.utf8('ipfs://test'),
        attributes
      ], deployer.address),
      
      Tx.contractCall('chroma-nft', 'list-token', [
        types.uint(1),
        types.uint(1000)
      ], deployer.address),
      
      Tx.contractCall('chroma-nft', 'purchase-token', [
        types.uint(1)
      ], buyer.address)
    ]);
    
    block.receipts[0].result.expectOk();
    block.receipts[1].result.expectOk();
    block.receipts[2].result.expectOk();
  }
});