Para conectar un Marketplace de NFTs ERC721 con un Smart Contract en Solidity que maneje transacciones de compra/venta y la expiración de NFTs, debes diseñar y desarrollar varios componentes clave tanto en el contrato inteligente como en la interfaz de usuario. A continuación, te proporciono una guía detallada sobre cómo estructurar este sistema, incluyendo ejemplos de código y explicaciones de cada parte.

1. Arquitectura General del Marketplace de NFTs
Componentes Principales:
Smart Contract ERC721: El contrato base que define los NFTs.
Smart Contract del Marketplace: Gestiona las transacciones de compra y venta, listados, y la expiración de NFTs.
Frontend (Interfaz de Usuario): Aplicación web que interactúa con los contratos inteligentes utilizando bibliotecas como Web3.js o Ethers.js.
Backend (Opcional): Servidor que puede gestionar datos adicionales, notificaciones, etc.
Servicios de Almacenamiento (IPFS): Para almacenar los metadatos y archivos de los NFTs de manera descentralizada.
2. Smart Contract ERC721
Primero, necesitas un contrato ERC721 que permita la creación y gestión de NFTs. Ya has proporcionado un ejemplo básico anteriormente, pero asegurémonos de que esté listo para interactuar con el Marketplace.
3. Smart Contract del Marketplace
El contrato del Marketplace manejará la lógica para listar, comprar, vender y expirar NFTs. A continuación, se presenta un ejemplo básico que puedes expandir según tus necesidades.
Explicación Detallada del Marketplace
Importaciones y Herencias:
IERC721: Interface del estándar ERC721 para interactuar con los contratos de NFTs.
ReentrancyGuard: Protección contra ataques de reentrancy (reentradas), asegurando que no se puedan ejecutar funciones de manera repetida antes de que finalice su ejecución.
Counters: Para gestionar contadores de listados de manera segura.
Estructura Listing:
listingId: Identificador único para cada listado.
nftContract: Dirección del contrato ERC721 del NFT.
tokenId: Identificador del token NFT.
seller: Dirección del vendedor.
price: Precio en Ether para la venta.
expirationTime: Timestamp que define cuándo expira el listado.
isActive: Estado del listado (activo o no).
Eventos:
ItemListed: Emite información cuando un NFT es listado para la venta.
ItemSold: Emite información cuando un NFT es vendido.
ItemCancelled: Emite información cuando un listado es cancelado o expira.
Funciones Principales:
listItem:

Propósito: Permitir a los propietarios de NFTs listar sus tokens para la venta.
Validaciones:
El precio debe ser mayor que cero.
El que lista debe ser el propietario del NFT.
El contrato del Marketplace debe estar aprobado para transferir el NFT.
Acciones:
Incrementa el contador de listados.
Crea un nuevo listado con los detalles proporcionados.
Emite el evento ItemListed.
buyItem:

Propósito: Permitir a los compradores adquirir NFTs listados.
Validaciones:
El listado debe estar activo.
El listado no debe haber expirado.
El comprador debe enviar suficiente Ether.
Acciones:
Marca el listado como inactivo.
Transfiere el NFT al comprador.
Transfiere el pago al vendedor.
Emite el evento ItemSold.
cancelListing:

Propósito: Permitir al vendedor cancelar un listado activo.
Validaciones:
El listado debe estar activo.
Solo el vendedor puede cancelar el listado.
Acciones:
Marca el listado como inactivo.
Emite el evento ItemCancelled.
removeExpiredListings:

Propósito: Revisar y desactivar listados que hayan expirado.
Acciones:
Itera sobre todos los listados.
Marca como inactivo los listados cuya expirationTime haya pasado.
Emite el evento ItemCancelled para cada listado expirado.
onERC721Received:

Propósito: Permitir que el contrato reciba NFTs mediante la interfaz ERC721.
Acción: Retorna el selector de la función para confirmar la recepción del NFT.
4. Gestión de Transacciones y Expiración de NFTs
Comprar/Vender NFTs:
Vender:

El propietario del NFT llama a listItem en el contrato del Marketplace, especificando el contrato del NFT, el tokenId, el precio y la duración del listado.
El contrato del Marketplace registra el listado y emite un evento.
Comprar:

Un comprador llama a buyItem, proporcionando el listingId y enviando la cantidad de Ether igual o superior al precio del listado.
El contrato verifica las condiciones, transfiere el NFT al comprador y el Ether al vendedor.
Marca el listado como inactivo y emite un evento de venta.
Expirar NFTs:
Cada listado tiene un expirationTime. Si el tiempo actual (block.timestamp) supera este valor, el listado ya no es válido.
Cualquier usuario puede llamar a removeExpiredListings para limpiar y desactivar los listados expirados.
Los listados expirados se marcan como inactivos y se emiten eventos de cancelación.
5. Consideraciones Adicionales
Seguridad:
ReentrancyGuard: Protege las funciones que manejan transferencias de Ether y NFTs para evitar ataques de reentrancy.
Validaciones: Asegúrate de validar todas las condiciones necesarias antes de realizar acciones críticas.
Eventos: Usa eventos para registrar acciones importantes, facilitando el seguimiento y la auditoría.
Optimización:
Gas Costs: Optimiza las iteraciones y el uso de almacenamiento para reducir los costos de gas.
Modularidad: Considera dividir el contrato en múltiples contratos si crece en complejidad.
Extensiones Futuras:
Royalties: Implementa un sistema de royalties para que los creadores reciban un porcentaje en cada venta secundaria.
Subastas: Añade funcionalidades para subastas de NFTs.
Filtros y Búsquedas: Mejora la experiencia del usuario permitiendo filtrar y buscar listados según diferentes criterios.
6. Integración con el Frontend
Para que el Marketplace sea funcional desde una interfaz web, necesitas conectar el frontend con los contratos inteligentes. Aquí hay un enfoque básico utilizando Ethers.js y React:

Ejemplo de Código (React + Ethers.js):
Explicación del Código:
Conexión a MetaMask:

Ethers.js se utiliza para conectar el frontend con la blockchain a través de MetaMask.
Se inicializan los contratos inteligentes del Marketplace y del Collectible usando sus ABI y direcciones.
Funciones Principales:

listNFT: Permite al usuario listar un NFT para la venta especificando el tokenId, el precio y la duración del listado.
buyNFT: Permite al usuario comprar un NFT listado proporcionando el listingId.
Interfaz de Usuario:

Muestra la cuenta conectada y provee botones y formularios para interactuar con los contratos.
7. Expiración de NFTs
La lógica de expiración ya está incluida en el contrato del Marketplace mediante la propiedad expirationTime. Sin embargo, es importante asegurarse de que los listados expirados no puedan ser comprados y que se limpien adecuadamente.

Automatización de Expiración:
Para automatizar la expiración de los listados, puedes implementar mecanismos como:

Funciones de Mantenimiento: Permitir que cualquier usuario llame a removeExpiredListings periódicamente para limpiar listados expirados.
Automatización Off-Chain: Utilizar servicios como Chainlink Keepers o scripts programados en el backend que llamen a la función de eliminación de listados expirados de manera regular.
8. Consideraciones Finales
Seguridad:
Validaciones Rigurosas: Asegúrate de validar todas las entradas y condiciones antes de ejecutar acciones críticas.
Pruebas Exhaustivas: Realiza pruebas unitarias y de integración para garantizar que todas las funcionalidades funcionen correctamente.
Auditoría: Considera auditar el contrato inteligente para identificar y corregir vulnerabilidades potenciales.
Optimización de Gas:
Eficiencia en el Código: Optimiza las funciones para minimizar el consumo de gas, especialmente en operaciones que se ejecutan frecuentemente.
Batching de Transacciones: Considera agrupar múltiples operaciones en una sola transacción cuando sea posible.
Interfaz de Usuario:
Usabilidad: Diseña una interfaz intuitiva que facilite a los usuarios listar y comprar NFTs.
Feedback en Tiempo Real: Proporciona retroalimentación inmediata sobre el estado de las transacciones (ej., usando notificaciones y estados de carga).
Extensiones Futuras:
Royalties: Implementa un sistema de royalties para que los creadores reciban un porcentaje en cada venta secundaria.
Subastas: Añade funcionalidades para subastas de NFTs.
Filtros y Búsquedas Avanzadas: Mejora la experiencia del usuario permitiendo filtrar y buscar listados según diferentes criterios (precio, fecha, propietario, etc.).
Conclusión
Conectar un Marketplace de NFTs ERC721 con un Smart Contract en Solidity requiere una combinación de contratos inteligentes robustos, una interfaz de usuario amigable y consideraciones de seguridad y optimización. Los ejemplos proporcionados te ofrecen una base sólida para empezar, pero es fundamental adaptar y expandir estas soluciones según las necesidades específicas de tu proyecto.
