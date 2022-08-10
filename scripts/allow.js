const { ethers, getNamedAccounts } = require("hardhat")

// approving the spending of Pirate Token
async function main() {
    const { deployer } = await getNamedAccounts()
    //getting the token contract
    const pirateToken = await ethers.getContractAt(
        "PirateToken",
        "0xACf8151332430109AAbc899411427935b7D941B5",
        deployer
    )

    //allowing the contract to use the pirate tokens
    const transactionResponse = await pirateToken.approve(
        "0xA8F22381cdBBf9a058dD4180F8F5356457b4D4d4",
        1000
    )
    await transactionResponse.wait(1)
    //logging the response
    console.log(transactionResponse)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
