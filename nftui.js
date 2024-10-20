import React, { useEffect, useState } from 'react';
import { ethers } from 'ethers';
import YourCollectibleABI from './abis/YourCollectible.json';
import NFTMarketplaceABI from './abis/NFTMarketplace.json';

const marketplaceAddress = "0xTuDireccionDeMarketplace";
const collectibleAddress = "0xTuDireccionDeCollectible";

function App() {
    const [provider, setProvider] = useState(null);
    const [signer, setSigner] = useState(null);
    const [collectibleContract, setCollectibleContract] = useState(null);
    const [marketplaceContract, setMarketplaceContract] = useState(null);
    const [account, setAccount] = useState('');

    useEffect(() => {
        const init = async () => {
            if (window.ethereum) {
                const tempProvider = new ethers.providers.Web3Provider(window.ethereum);
                setProvider(tempProvider);
                const tempSigner = tempProvider.getSigner();
                setSigner(tempSigner);
                const tempAccount = await tempSigner.getAddress();
                setAccount(tempAccount);
                const tempCollectible = new ethers.Contract(collectibleAddress, YourCollectibleABI, tempSigner);
                setCollectibleContract(tempCollectible);
                const tempMarketplace = new ethers.Contract(marketplaceAddress, NFTMarketplaceABI, tempSigner);
                setMarketplaceContract(tempMarketplace);
            } else {
                alert('Por favor instala MetaMask!');
            }
        };
        init();
    }, []);

    const listNFT = async (tokenId, price, duration) => {
        try {
            const tx = await marketplaceContract.listItem(collectibleAddress, tokenId, ethers.utils.parseEther(price), duration);
            await tx.wait();
            alert('NFT listado exitosamente!');
        } catch (error) {
            console.error(error);
            alert('Error al listar el NFT');
        }
    };

    const buyNFT = async (listingId) => {
        try {
            const listing = await marketplaceContract.listings(listingId);
            const tx = await marketplaceContract.buyItem(listingId, { value: listing.price });
            await tx.wait();
            alert('NFT comprado exitosamente!');
        } catch (error) {
            console.error(error);
            alert('Error al comprar el NFT');
        }
    };

    return (
        <div>
            <h1>Marketplace de NFTs</h1>
            <p>Cuenta conectada: {account}</p>
            {/* Aquí agregarías formularios y botones para listar y comprar NFTs */}
        </div>
    );
}

export default App;