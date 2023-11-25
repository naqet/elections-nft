import { ethers } from "hardhat";
import { ElectionsLogic } from "../typechain-types";
import { writeFile } from "fs";

const parties = ["Gondor", "Rohan", "Bag Eng"];

const candidates = [
  {
    party: "Gondor",
    name: "Aragorn",
  },
  {
    party: "Gondor",
    name: "Legolas",
  },
  {
    party: "Gondor",
    name: "Gimli",
  },
  {
    party: "Rohan",
    name: "Gandalf",
  },
  {
    party: "Rohan",
    name: "Frodo",
  },
  {
    party: "Bag Eng",
    name: "Sam",
  },
  {
    party: "Bag Eng",
    name: "Pippin",
  },
];

async function main() {
  const nftAddress = await handleNfts();
  const logic = await handleLogic(nftAddress);

  const candidates = await logic.getAllCandidates();

  const result = convertToCSV(candidates);

  writeFile("./votes.csv", result, (err) => {
    if (err) throw err;

    console.log("File created successfuly");
  });
}

async function handleNfts(): Promise<string> {
  const [_, ...accs] = await ethers.getSigners();

  const contract = await ethers.deployContract("Elections");
  const address = await contract.getAddress();
  await contract.waitForDeployment();
  console.log(`Deployed NFT contract: ${address}`);

  console.log("Minting...");
  for (const acc of accs) {
    await contract.connect(acc).safeMint();
  }

  const count = await contract.tokenCount();
  console.log("Minted: ", Number(count));
  return address;
}

async function handleLogic(nftAddress: string): Promise<ElectionsLogic> {
  const [owner, ...accs] = await ethers.getSigners();

  const contract = await ethers.deployContract("ElectionsLogic", [nftAddress]);
  await contract.waitForDeployment();
  const address = await contract.getAddress();
  console.log(`Deployed Logic contract: ${address}`);

  for (const party of parties) {
    await contract.addParty(party);
  }

  for (const candidate of candidates) {
    await contract.addCandidate(candidate.party, candidate.name);
  }

  // Start voting
  console.log("Voting...");
  await contract.toggleVoting();

  for (const acc of accs) {
    const idx = getRandomInt(0, candidates.length);
    const randomCanditate = candidates[idx];
    await contract
      .connect(acc)
      .vote(randomCanditate.party, randomCanditate.name);
  }

  // End voting
  await contract.connect(owner).toggleVoting();
  console.log("Voting complete");

  return contract;
}

function getRandomInt(min: number, max: number): number {
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min) + min);
}

function convertToCSV(value: Record<any, any>[]) {
  const keys = Object.keys(value[0]);

  // When we receive results from the contract, we don't get the keys of
  // candidate object, so we need to build the header manually

  // Build header
  let result = "ID,VOTES_COUNT,PARTY,NAME" + "\n";

  // Add the rows
  value.forEach((obj) => {
    result += keys.map((k) => obj[k]).join(",") + "\n";
  });

  return result;
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
