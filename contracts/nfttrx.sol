// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is Ownable {
    struct Listing {
        address seller;
        uint256 price;
        uint256 expiration;  // Timestamp de expiración de la venta
    }

    // Mapeo de tokenId a su respectiva lista de venta
    mapping(address => mapping(uint256 => Listing)) public listings;

    event NFTListed(address indexed nftContract, uint256 indexed tokenId, address indexed seller, uint256 price, uint256 expiration);
    event NFTBought(address indexed nftContract, uint256 indexed tokenId, address indexed buyer, uint256 price);
    event NFTDelisted(address indexed nftContract, uint256 indexed tokenId);

    // Listar un NFT para la venta
    function listNFT(address nftContract, uint256 tokenId, uint256 price, uint256 expiration) external {
        IERC721 nft = IERC721(nftContract);

        require(nft.ownerOf(tokenId) == msg.sender, "Solo el propietario puede listar");
        require(nft.isApprovedForAll(msg.sender, address(this)), "Marketplace no está aprobado para transferir este NFT");

        listings[nftContract][tokenId] = Listing(msg.sender, price, expiration);

        emit NFTListed(nftContract, tokenId, msg.sender, price, expiration);
    }

    // Comprar un NFT listado
    function buyNFT(address nftContract, uint256 tokenId) external payable {
        Listing memory listing = listings[nftContract][tokenId];
        
        require(listing.seller != address(0), "Este NFT no está en venta");
        require(msg.value >= listing.price, "El valor enviado no es suficiente");
        require(block.timestamp <= listing.expiration, "Este NFT ya expiró");

        // Transferir el NFT al comprador
        IERC721(nftContract).safeTransferFrom(listing.seller, msg.sender, tokenId);

        // Transferir los fondos al vendedor
        payable(listing.seller).transfer(msg.value);

        // Eliminar el listado de venta
        delete listings[nftContract][tokenId];

        emit NFTBought(nftContract, tokenId, msg.sender, msg.value);
    }

    // Quitar un NFT de la venta
    function delistNFT(address nftContract, uint256 tokenId) external {
        Listing memory listing = listings[nftContract][tokenId];

        require(listing.seller == msg.sender, "Solo el vendedor puede quitar el NFT de la venta");

        delete listings[nftContract][tokenId];

        emit NFTDelisted(nftContract, tokenId);
    }

    // Función de fallback para recibir pagos
    receive() external payable {}
}