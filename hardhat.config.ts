require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();  // Cargar las variables de entorno

module.exports = {
  solidity: "0.8.4",
  networks: {
    // Red local
    localhost: {
      url: "http://127.0.0.1:8545"
    },
    // Sepolia testnet
    sepolia: {
      url: `https://sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`, // O usa el proveedor que prefieras (e.g., Alchemy)
      accounts: [`0x${process.env.DEPLOYER_PRIVATE_KEY}`], // Clave privada de la cuenta que hará el deploy
      chainId: 11155111, // El ID de cadena para Sepolia
    },
    // Goerli testnet
    goerli: {
      url: `https://goerli.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [`0x${process.env.DEPLOYER_PRIVATE_KEY}`], // Clave privada de la cuenta para Goerli
      chainId: 5, // El ID de cadena para Goerli
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY, // Para verificar contratos en etherscan
  },
};
