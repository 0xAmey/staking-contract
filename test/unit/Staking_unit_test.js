const { assert, expect } = require("chai")
const { network, getNamedAccounts, deployments, ethers } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config")

!developmentChains.includes(network.name) //if the network name is not included then skip or else *run the test*
    ? describe.skip
    : describe("Staking unit test", async () => {
          let staking, deployer

          beforeEach(async () => {
              deployer = (await getNamedAccounts()).deployer
              await deployments.fixture(["all"])
              staking = await ethers.getContract(
                  "Staking",
                  //"0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512",
                  deployer
              ) //get the deployed contract and connect it to the deployer
              //console.log(staking.address)
          })

          describe("constructor", () => {
              it("should assign the staking token adddress correctly", async () => {
                  const tokenAddy = "0xACf8151332430109AAbc899411427935b7D941B5"
                  assert.equal(tokenAddy, await staking.getStakingTokenAddress())
                  assert.equal(tokenAddy, await staking.getRewardsTokenAddress())
              })
          })

          describe("update reward modifier", () => {
              it("should update the timestamp when any of the attached functions are called", async () => {
                  const transactionResponse = await staking.stake("10")
                  const txReceipt = await transactionResponse.wait(1)
                  timestamp = await staking.getLastCall()
                  assert.equal(timestamp, block.timestamp)
              })
          })
      })
