import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

// Existing tests remain the same

Clarinet.test({
  name: "Cannot batch list with duplicate token IDs",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    let tokenIds = [types.uint(1), types.uint(1)];
    
    let block = chain.mineBlock([
      Tx.contractCall('chroma-nft', 'batch-list', [
        types.list(tokenIds),
        types.uint(1000)
      ], deployer.address)
    ]);
    
    block.receipts[0].result.expectErr(107);
  }
});

Clarinet.test({
  name: "Can cancel listing",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    let tokenId = types.uint(1);
    
    let block = chain.mineBlock([
      Tx.contractCall('chroma-nft', 'batch-list', [
        types.list([tokenId]),
        types.uint(1000)
      ], deployer.address),
      Tx.contractCall('chroma-nft', 'cancel-listing', [
        tokenId
      ], deployer.address)
    ]);
    
    block.receipts[1].result.expectOk();
  }
});
