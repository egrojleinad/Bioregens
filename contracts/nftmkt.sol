// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _listingIdCounter;

    struct Listing {
        uint256 listingId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        uint256 price;
        uint256 expirationTime; // Timestamp de expiración
        bool isActive;
    }

    mapping(uint256 => Listing) public listings;

    event ItemListed(
        uint256 indexed listingId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        uint256 price,
        uint256 expirationTime
    );

    event ItemSold(
        uint256 indexed listingId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address buyer,
        uint256 price
    );

    event ItemCancelled(uint256 indexed listingId);

    // Listar un NFT para la venta
    function listItem(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        uint256 duration // Duración en segundos para la expiración
    ) external nonReentrant {
        require(price > 0, "El precio debe ser mayor que cero");

        IERC721 nft = IERC721(nftContract);
        require(nft.ownerOf(tokenId) == msg.sender, "No eres el propietario del NFT");
        require(nft.getApproved(tokenId) == address(this) || nft.isApprovedForAll(msg.sender, address(this)),
            "El Marketplace no está aprobado para transferir este NFT");

        _listingIdCounter.increment();
        uint256 listingId = _listingIdCounter.current();

        listings[listingId] = Listing({
            listingId: listingId,
            nftContract: nftContract,
            tokenId: tokenId,
            seller: payable(msg.sender),
            price: price,
            expirationTime: block.timestamp + duration,
            isActive: true
        });

        emit ItemListed(listingId, nftContract, tokenId, msg.sender, price, block.timestamp + duration);
    }

    // Comprar un NFT listado
    function buyItem(uint256 listingId) external payable nonReentrant {
        Listing storage listing = listings[listingId];
        require(listing.isActive, "El listado no está activo");
        require(block.timestamp <= listing.expirationTime, "El listado ha expirado");
        require(msg.value >= listing.price, "No has enviado suficiente Ether");

        listing.isActive = false;

        // Transferir el NFT al comprador
        IERC721(listing.nftContract).safeTransferFrom(listing.seller, msg.sender, listing.tokenId);

        // Transferir el pago al vendedor
        listing.seller.transfer(listing.price);

        emit ItemSold(listingId, listing.nftContract, listing.tokenId, msg.sender, listing.price);
    }

    // Cancelar un listado
    function cancelListing(uint256 listingId) external nonReentrant {
        Listing storage listing = listings[listingId];
        require(listing.isActive, "El listado no está activo");
        require(listing.seller == msg.sender, "No eres el vendedor de este NFT");

        listing.isActive = false;

        emit ItemCancelled(listingId);
    }

    // Función para verificar y eliminar listados expirados
    function removeExpiredListings() external nonReentrant {
        for (uint256 i = 1; i <= _listingIdCounter.current(); i++) {
            Listing storage listing = listings[i];
            if (listing.isActive && block.timestamp > listing.expirationTime) {
                listing.isActive = false;
                emit ItemCancelled(listing.listingId);
            }
        }
    }

    // Recepción de NFTs
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}