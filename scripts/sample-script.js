const {ether} = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    const NFT = await ethers.getContractFactory("Medal");
    const nft = await NFT.deploy("https://mobiapi.owens.market/uri/", 2, deployer.address, deployer.address, deployer.address);

    console.log("NFT deployed at", nft.address);
}

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
})