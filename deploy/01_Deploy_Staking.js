const { getNamedAccounts, deployments, network } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../helper-functions")
const { getContractAddress } = require("ethers/lib/utils")

//const tokenAddress = getContractAddress("PirateToken")

const tokenAddress = "0xACf8151332430109AAbc899411427935b7D941B5"

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const StakingContract = await deploy("Staking", {
        from: deployer,
        args: [tokenAddress, tokenAddress],
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
    log(" ")
    log(`Staking Contract deployed at ${StakingContract.address}`)

    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        await verify(StakingContract.address, [tokenAddress, tokenAddress])
    }
}

module.exports.tags = ["all", "token"]
