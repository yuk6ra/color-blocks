const { ethers } = require("hardhat");

describe("NFT", function() {
    it("", async function () {
        const nftContractFactory = await ethers.getContractFactory("ColorBlocks");
        const nftContract = await nftContractFactory.deploy();
        await nftContract.deployed();
        console.log("Contract deployed to:", nftContract.address);
    
    
        let i = 10;
        for (i=10; i<20; i++){
          let txn = await nftContract.mintNFT();
          await txn.wait();
          console.log("%d 回目", i);
        };
    
    
        console.log("Done");    
    })
})

