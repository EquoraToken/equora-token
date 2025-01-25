const hre = require("hardhat");

async function main() {
    const charityWallet = process.env.CHARITY_WALLET;
    const adminWallet = process.env.ADMIN_WALLET;

    if (!charityWallet || !adminWallet) {
        throw new Error("Missing CHARITY_WALLET or ADMIN_WALLET in .env");
    }

    console.log("Deploying EquoraToken with the following wallets:");
    console.log(`Charity Wallet: ${charityWallet}`);
    console.log(`Admin Wallet: ${adminWallet}`);

    const EquoraToken = await hre.ethers.getContractFactory("EquoraToken");
    const equoraToken = await EquoraToken.deploy(charityWallet, adminWallet);

    await equoraToken.waitForDeployment();

    console.log("EquoraToken deployed to:", await equoraToken.getAddress());

    const [deployer] = await hre.ethers.getSigners();
    console.log("Excluding deployer wallet from fees:", deployer.address);
    await equoraToken.excludeFromFee(deployer.address, true);

    console.log("Excluding charity and admin wallets from fees...");
    await equoraToken.excludeFromFee(charityWallet, true);
    await equoraToken.excludeFromFee(adminWallet, true);

    console.log("All wallets excluded from fees!");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
