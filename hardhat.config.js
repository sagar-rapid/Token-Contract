require('@nomiclabs/hardhat-waffle');
require("@nomiclabs/hardhat-etherscan");
require("hardhat-gas-reporter");
const dotenv = require('dotenv');
dotenv.config();

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();
  for (const account of accounts) {
    console.log(account.address);
  }
});

// task("verify_contract","verifying all contract",async(taskArgs,hre) =>{
//   await hre.run("verify:verify", {
//       address: "0xc3d73F6Df1442Fd084Ce343112Ba0458be833a5d",
//       constructorArguments: ["https://mobiapi.owens.market/uri/", "0xb11f09290AaeD4aEe4e98aecBF986Bd2262D2718", "0xb11f09290AaeD4aEe4e98aecBF986Bd2262D2718", "0xb11f09290AaeD4aEe4e98aecBF986Bd2262D2718"],
//       });
// })

task("verify_contract","verifying all contract",async(taskArgs,hre) =>{
    await hre.run("verify:verify", {
        address: "0x849fB1141Df741326caF2f2260458f3CC76aEcCe",
        constructorArguments: ["https://mobiapi.owens.market/uri/", 2, "0xb11f09290AaeD4aEe4e98aecBF986Bd2262D2718", "0xb11f09290AaeD4aEe4e98aecBF986Bd2262D2718", "0xb11f09290AaeD4aEe4e98aecBF986Bd2262D2718"],
        });
  })

module.exports = {
    networks: {
    	testnet: {
      		url: "https://matic-testnet-archive-rpc.bwarelabs.com",
      		chainId: 80001,
      		accounts: [process.env.DEPLOYER_PRIVATE_KEY]
    	},
    	mainnet: {
      		url: "https://bsc-dataseed.binance.org/",
      		chainId: 56,
      		accounts: [process.env.DEPLOYER_PRIVATE_KEY]
    	},
    	localhost: {
      		url: "http://127.0.0.1:8545"
    	},
        bsc: {
            url: process.env.MAIN_NET_API_URL,
            accounts: [process.env.DEPLOYER_PRIVATE_KEY],
        },
        fork: {
            url: 'http://localhost:8545',
        },
        hardhat: {
            forking: {
                url: process.env.MAIN_NET_API_URL,
            }
        },
    },
    etherscan: {
        apiKey: process.env.BSCSCAN_API_KEY,
    },
    solidity: {
        version: "0.8.11",
        settings: {
            optimizer: {
                enabled: true,
                runs: 200,
            },
        },
    },
};