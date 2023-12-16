const Web3 = require("web3");

const provider = new Web3.providers.HttpProvider("https://mainnet.infura.io/v3/YOUR_INFURA_KEY");
const web3 = new Web3(provider);

const contractAddress = "0xYOUR_CONTRACT_ADDRESS";
const contractABI = require("./contract.abi");

const contract = new web3.eth.Contract(contractABI, contractAddress);

// Sözleşmeyi dağıt
contract.methods.myFunction().send({
  from: "YOUR_WALLET_ADDRESS",
  value: "YOUR_AMOUNT_OF_ETHER",
});

// Sözleşmenin durumunu kontrol et
const contractBalance = contract.methods.balance().call();

console.log("Sözleşme bakiyesi:", contractBalance);

