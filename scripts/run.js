const main = async () => {
    const nftContractFactory = await hre.ethers.getContractFactory("DotSquiggle");
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

    // // let txn_color = await nftContract._generateColor(3);
    // // await txn_color.wait();

    // let txn1 = await nftContract.mintNFT();
    // await txn1.wait();

    // let txn2 = await nftContract.mintNFT();
    // await txn2.wait();

    // let txn3 = await nftContract.mintNFT();
    // await txn3.wait();

    // let txn4 = await nftContract.mintNFT();
    // await txn4.wait();

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