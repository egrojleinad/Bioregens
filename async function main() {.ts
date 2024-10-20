async function main() {
    const YourCollectible = await ethers.getContractFactory("YourCollectible");
    const yourCollectible = await YourCollectible.deploy();
    await yourCollectible.deployed();
  
    console.log("YourCollectible deployed to:", yourCollectible.address);
  
    const NFTMarketplace = await ethers.getContractFactory("NFTMarketplace");
    const marketplace = await NFTMarketplace.deploy();
    await marketplace.deployed();
  
    console.log("Marketplace deployed to:", marketplace.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
  