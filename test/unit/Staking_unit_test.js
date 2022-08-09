const { assert, expect } = require("chai")
const { network, getNamedAccounts, deployments, ethers } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")

!developmentChains.includes(network.name) //if the network name is not included then skip or else *run the test*
    ? describe.skip
    : describe("Staking unit test", async () => {
          let staking, deployer
          const chainId = network.config.chainId

          beforeEach(async () => {
              deployer = (await getNamedAccounts()).deployer
              await deployments.fixture(["all"])
              staking = await ethers.getContract("Staking", deployer) //get the deployed contract and connect it to the deployer
          })

          describe("constructor", () => {
              it("should assign the staking token adddress correctly", async () => {
                  const tokenAddy = "0xACf8151332430109AAbc899411427935b7D941B5"
                  assert.equal(tokenAddy, await staking.getStakingTokenAddress())
                  assert.equal(tokenAddy, await staking.getRewardsTokenAddress())
              })
          })
      })
