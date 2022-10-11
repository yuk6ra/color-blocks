const main = async () => {
    const nftContractFactory = await hre.ethers.getContractFactory("ColorBlocks");
    const nftContract = await nftContractFactory.deploy();
    await nftContract.deployed();
    console.log("Contract deployed to:", nftContract.address);


    let i = 10;
    for (i=10; i<20; i++){
      let txn = await nftContract.mintNFT();
      await txn.wait();
      console.log("%d 回目", i);
      // let text = await nftContract.dataURI(i);
      // try {
      //     fs.appendFileSync('./test/output/1.txt', text, 'utf-8');
      // } catch (err) {
      //     console.log(err);
      // }
    };


    console.log("Done");



};
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  runMain();