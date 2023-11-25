# Elections NFT

Voting system with NFT ownership verification

```shell
npm install
npx hardhat compile
```

To run hardhat local blockchain:
```shell
npx hardhat node
```

To execute voting.ts file.
```shell
npx hardhat run --network localhost scripts/voting.ts
```

After this command there should be voting.csv file available with results for each candidate

## Config
- To change the number of voters (available addresses), check hardhat.config.ts. Changing count parameter, changes the amount of addresses available.
First address is used for deployments etc. and is excluded from voting. If you want to have 100 voters, change count to 101.

- To change available parties/candidates edit scripts/voting.ts file.
