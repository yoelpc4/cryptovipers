# cryptovipers

## Project setup
```
yarn install
```

### Compiles and hot-reloads for development

```
yarn serve
```

### Compiles and minifies for production

```
yarn build
```

### Lints and fixes files

```
yarn lint
```

### Customize configuration

See [Configuration Reference](https://cli.vuejs.org/config/).

## Smart Contract

### Development

- Open [Remix IDE](https://remix.ethereum.org/) then make file `ViperToken.sol` then copy the `src/contracts/ViperToken.sol` content.

### Compile

- Choose version `0.8.0+commit.c7dfd78e` and language `Solidity`, then press `Compile ViperToken.sol` button.
- Copy the `ABI` then paste as the `contractAbi` value on `src/contracts/abi.js`.

### Deployment

- Choose environment `Injected Web3`, select your account, choose `Viper Token - contracts/ViperToken.sol`, then click `Deploy` button.
- Copy the deployed contract block address then paste as the `contractAddress` value on `src/App.vue`
