const { ethers, getNamedAccounts } = require("hardhat")

// approving the spending of Pirate Token
async function main() {
    const { deployer } = await getNamedAccounts()
    const pirateToken = await ethers.getContractAt(
        "PirateToken",
        "0xACf8151332430109AAbc899411427935b7D941B5",
        deployer
    )

    const transactionResponse = await pirateToken.approve(
        "0x5b06696ccBb49845b8997EC32034B6477361d64c",
        1000
    )
    await transactionResponse.wait(1)
    console.log(transactionResponse)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
