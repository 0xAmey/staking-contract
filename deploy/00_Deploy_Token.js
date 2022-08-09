const { getNamedAccounts, deployments, network } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../helper-functions")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const PirateToken = await deploy("PirateToken", {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
    log(" ")
    log(`Pirate Token deployed at ${PirateToken.address}`)

    // verifying the contract (it didn't work for this token for some reason)
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        await verify(PirateToken.address, [])
    }
}

module.exports.tags = ["all", "token"]
