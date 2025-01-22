const hre = require("hardhat");

async function main() {
    // Get the contract factory
    const EquoraToken = await hre.ethers.getContractFactory("EquoraToken");

    // Deploy the contract
    const equoraToken = await EquoraToken.deploy();

    // Wait for deployment to be finalized
    await equoraToken.waitForDeployment();

    // Log the deployed contract address
    console.log("EquoraToken deployed to:", equoraToken.target);
}

// Run the deployment script
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
