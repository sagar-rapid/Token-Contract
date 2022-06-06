const {ether} = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    const NFT = await ethers.getContractFactory("MyNFT");
    const nft = await NFT.deploy("https://mobiapi.owens.market/uri/", deployer.address, deployer.address, deployer.address);

    console.log("NFT deployed at", nft.address);

    // const Token = await ethers.getContractFactory("Token");
    // const token = await Token.deploy("Token","TKN");

    // console.log("Token deployed at", token.address);
}

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
})