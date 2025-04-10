# Merlin Token (MRN) - Deployment Guide

Este repositorio contiene el contrato inteligente para el token MRN de Merlin, un token ERC20 basado en mérito que recompensa las contribuciones de valor al ecosistema.

## Requisitos previos

- [Node.js](https://nodejs.org/) (v14 o superior)
- [npm](https://www.npmjs.com/) (viene con Node.js)
- Wallet compatible con Ethereum (como [MetaMask](https://metamask.io/))
- ETH para pagar las tarifas de gas (o tokens nativos si usas una red alternativa)

## Instalación

1. Clona este repositorio:
```bash
git clone <url-del-repositorio>
cd crypto
```

2. Instala las dependencias:
```bash
npm init -y
npm install hardhat @openzeppelin/contracts @nomiclabs/hardhat-ethers ethers dotenv
```

3. Inicializa el proyecto Hardhat:
```bash
npx hardhat init
```
Selecciona "Create a JavaScript project" cuando se te pregunte.

4. Configura las variables de entorno:
   - Crea un archivo `.env` en la raíz del proyecto
   - Añade tu clave privada y URL de API (como Infura o Alchemy):
```
PRIVATE_KEY=tu_clave_privada_aqui_sin_0x
ALCHEMY_API_KEY=tu_api_key_de_alchemy
INFURA_API_KEY=tu_api_key_de_infura
```
⚠️ NUNCA compartas tu clave privada ni la subas a repositorios públicos.

## Estructura de archivos

Después de la inicialización, tu directorio debe tener esta estructura:

```
crypto/
├── contracts/
│   └── MerlinToken.sol
├── scripts/
│   └── deploy.js
├── test/
├── .env
├── hardhat.config.js
└── README.md
```

## Configuración

1. Modifica `hardhat.config.js` para incluir las redes donde desplegarás:

```javascript
require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;

module.exports = {
  solidity: "0.8.20",
  networks: {
    // Red principal de Ethereum (costosa)
    mainnet: {
      url: `https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [`0x${PRIVATE_KEY}`]
    },
    // Red de prueba Goerli (para testear, ETH gratis)
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [`0x${PRIVATE_KEY}`]
    },
    // Polygon (mucho más económico que Ethereum)
    polygon: {
      url: `https://polygon-mainnet.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [`0x${PRIVATE_KEY}`]
    },
    // Mumbai (testnet de Polygon, para pruebas)
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [`0x${PRIVATE_KEY}`]
    }
  }
};
```

2. Crea un script de despliegue en `scripts/deploy.js`:

```javascript
const hre = require("hardhat");

async function main() {
  // Obtén la dirección del desplegador (será el propietario inicial)
  const [deployer] = await ethers.getSigners();
  console.log("Desplegando contratos con la cuenta:", deployer.address);
  console.log("Saldo de la cuenta:", (await deployer.getBalance()).toString());

  // Despliega el contrato
  const MerlinToken = await hre.ethers.getContractFactory("MerlinToken");
  const merlinToken = await MerlinToken.deploy(deployer.address);

  await merlinToken.deployed();

  console.log("MerlinToken desplegado en:", merlinToken.address);
  console.log("Propietario:", await merlinToken.owner());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

## Despliegue

### Pruebas en Red de Prueba (Recomendado)

Antes de gastar ETH real, prueba en una red de prueba:

1. Obtén tokens ETH de prueba:
   - Para Goerli: https://goerlifaucet.com/
   - Para Mumbai: https://mumbaifaucet.com/

2. Despliega en la red de prueba:
```bash
npx hardhat run scripts/deploy.js --network goerli
```

### Despliegue en Mainnet

Una vez que hayas probado todo y estés listo para el lanzamiento real:

```bash
npx hardhat run scripts/deploy.js --network mainnet
```

⚠️ Esto requerirá ETH real para pagar el gas (aproximadamente $20-50 USD).

### Alternativa económica: Despliegue en Polygon

Para ahorrar en costos de gas:

```bash
npx hardhat run scripts/deploy.js --network polygon
```

## Interactuar con el contrato

Después del despliegue, puedes interactuar con tu contrato:

### Crear tokens (mint)

```javascript
// scripts/mint.js
const hre = require("hardhat");

async function main() {
  const tokenAddress = "DIRECCIÓN_DE_TU_CONTRATO_AQUÍ";
  const recipientAddress = "DIRECCIÓN_DEL_DESTINATARIO_AQUÍ";
  const amount = ethers.utils.parseEther("1000"); // 1000 tokens

  const MerlinToken = await hre.ethers.getContractFactory("MerlinToken");
  const merlinToken = await MerlinToken.attach(tokenAddress);

  // Minting tokens
  console.log("Minteo de tokens en progreso...");
  const tx = await merlinToken.mint(recipientAddress, amount);
  await tx.wait();
  console.log("Tokens minteados exitosamente!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

Ejecutar:
```bash
npx hardhat run scripts/mint.js --network mainnet
```

### Habilitar transferencias

```javascript
// scripts/enableTransfers.js
const hre = require("hardhat");

async function main() {
  const tokenAddress = "DIRECCIÓN_DE_TU_CONTRATO_AQUÍ";

  const MerlinToken = await hre.ethers.getContractFactory("MerlinToken");
  const merlinToken = await MerlinToken.attach(tokenAddress);

  console.log("Habilitando transferencias...");
  const tx = await merlinToken.enableTransfers();
  await tx.wait();
  console.log("Transferencias habilitadas exitosamente!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

Ejecutar:
```bash
npx hardhat run scripts/enableTransfers.js --network mainnet
```

### Configurar dirección de recuperación

```javascript
// scripts/setupRecovery.js
const hre = require("hardhat");

async function main() {
  const tokenAddress = "DIRECCIÓN_DE_TU_CONTRATO_AQUÍ";
  const recoveryAddress = "DIRECCIÓN_DE_RECUPERACIÓN_AQUÍ";

  const MerlinToken = await hre.ethers.getContractFactory("MerlinToken");
  const merlinToken = await MerlinToken.attach(tokenAddress);

  console.log("Configurando dirección de recuperación...");
  const tx = await merlinToken.setupRecoveryAddress(recoveryAddress);
  await tx.wait();
  console.log("Dirección de recuperación configurada exitosamente!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

Ejecutar:
```bash
npx hardhat run scripts/setupRecovery.js --network mainnet
```

## Verificación del contrato

Para que los usuarios puedan ver y verificar el código del contrato en Etherscan:

1. Instala el plugin:
```bash
npm install @nomiclabs/hardhat-etherscan
```

2. Agrega a `hardhat.config.js`:
```javascript
require("@nomiclabs/hardhat-etherscan");

// Añade esto a la configuración
etherscan: {
  apiKey: process.env.ETHERSCAN_API_KEY
}
```

3. Verifica el contrato:
```bash
npx hardhat verify --network mainnet DIRECCIÓN_DEL_CONTRATO DIRECCIÓN_DEL_PROPIETARIO
```

## Listado en Uniswap

Después de desplegar tu token MRN y haber minteado una cantidad inicial, puedes listarlo en Uniswap para permitir el intercambio entre MRN y otras criptomonedas.

### Requisitos previos para listar en Uniswap

1. Token MRN desplegado y verificado
2. Transferencias habilitadas (`enableTransfers()`)
3. Una cantidad de tokens MRN para crear el pool de liquidez
4. ETH (o el token nativo de la red que uses) para emparejar con MRN
5. ETH adicional para pagar tarifas de gas

### Proceso para listar en Uniswap V3

1. **Preparación para crear el pool:**
   - Mint una cantidad adecuada de tokens MRN a tu dirección (al menos unos miles)
   - Asegúrate de tener suficiente ETH para emparejar (valor similar al de los tokens MRN)
   - Las transferencias deben estar habilitadas

2. **Crear el pool de liquidez:**
   
   a. Visita [Uniswap](https://app.uniswap.org/#/pool) y conecta tu wallet
   
   b. Haz clic en "New Position"
   
   c. Si tu token no aparece automáticamente, ingresa la dirección del contrato MRN
   
   d. Selecciona ETH (o WETH) como el otro token del par
   
   e. Elige rango de precios:
      - Para V3: selecciona un rango de precios para concentrar liquidez
      - Recomendación: comienza con un rango amplio para tokens nuevos
   
   f. Ingresa las cantidades que deseas añadir como liquidez inicial:
      - Se recomienda un valor mínimo de $1,000-5,000 USD en equivalente
      - Esto es crucial para crear un mercado inicial viable

   g. Confirma la transacción y paga el gas

3. **Verificar que el pool está activo:**
   - Comprueba que tu pool aparece en "Your Positions"
   - Verifica que el token aparece en la interfaz de intercambio de Uniswap

### Script para aprobar Uniswap para usar tus tokens

```javascript
// scripts/approveUniswap.js
const hre = require("hardhat");

async function main() {
  const tokenAddress = "DIRECCIÓN_DE_TU_CONTRATO_AQUÍ";
  // Router de Uniswap V3
  const uniswapRouterAddress = "0xE592427A0AEce92De3Edee1F18E0157C05861564";
  // Aprobación máxima (ajusta según necesidades)
  const maxApproval = ethers.constants.MaxUint256;
  
  const MerlinToken = await hre.ethers.getContractFactory("MerlinToken");
  const merlinToken = await MerlinToken.attach(tokenAddress);

  console.log("Aprobando Uniswap para usar tus tokens MRN...");
  const tx = await merlinToken.approve(uniswapRouterAddress, maxApproval);
  await tx.wait();
  console.log("Aprobación exitosa! Ahora puedes crear un pool en Uniswap.");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

Ejecutar:
```bash
npx hardhat run scripts/approveUniswap.js --network mainnet
```

### Alternativa: Listar en Uniswap en Polygon

Para costos mucho más bajos, puedes crear un pool en Uniswap en la red Polygon:

1. Despliega tu token en Polygon
2. Sigue los mismos pasos anteriores, pero conectándote a Polygon en tu wallet
3. Usa MATIC en lugar de ETH para crear el pool

### Después de crear liquidez

1. **Compartir la dirección del pool:**
   - Comparte la URL de tu pool en redes sociales y comunidades
   - Ejemplo: `https://app.uniswap.org/#/pool/ID_DEL_POOL`

2. **Monitorear y mantener liquidez:**
   - Vigila el pool para asegurarte que siempre haya suficiente liquidez
   - Considera añadir liquidez adicional si es necesario

3. **Promocionar tu token:**
   - Anuncia la disponibilidad de tu token en Uniswap
   - Proporciona tutoriales para que los usuarios puedan comprar MRN fácilmente

## Próximos pasos

1. **Solicitar listado en agregadores** como CoinMarketCap o CoinGecko
2. **Implementar staking o governance** para aumentar la utilidad del token
3. **Considerar pools de liquidez incentivados** para atraer más usuarios

## Consideraciones de seguridad

- Mantén tu clave privada segura
- Considera usar una wallet hardware como Ledger o Trezor
- Realiza auditorías antes de manejar cantidades significativas
- Implementa cambios con precaución y pruebas exhaustivas

## Recursos adicionales

- [Documentación de Hardhat](https://hardhat.org/docs)
- [Documentación de OpenZeppelin](https://docs.openzeppelin.com/)
- [Guía ERC20 de Ethereum](https://ethereum.org/en/developers/docs/standards/tokens/erc-20/)