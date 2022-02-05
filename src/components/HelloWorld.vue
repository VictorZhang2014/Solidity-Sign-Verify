<template>
  <div class="hello">
    <h1>{{ msg }}</h1> 
    <h3></h3>
    <ul>
      <li><a href="javascript:;" @click="connectToMetamask" rel="noopener">1. Connect with MetaMask</a></li> 
    </ul>
    <ul>
      <li><a href="javascript:;" @click="solMessageHash" rel="noopener">2. Solidity Contract: Message Hash</a></li>
    </ul>
    <ul>
      <li><a href="javascript:;" @click="MetaMaskSignedMsgHash" rel="noopener">3. MetaMask: the hash signs</a></li>
    </ul>
    <ul>
      <li><a href="javascript:;" @click="solVerify" rel="noopener">4. Solidity Contract: Verify Signature</a></li>
    </ul>
    <ul>
      <li><a href="javascript:;" @click="web3MessageHash" rel="noopener">Generate signature by web3.js instead of contract, it's an alternative with step-2</a></li>
    </ul>
  </div>
</template>

<script>
import Web3 from "web3";

export default {
  name: 'HelloWorld',
  props: {
    msg: String,
  },
  methods: {
    // https://solidity-by-example.org/signature/

    connectToMetamask: async function () {
      if (window.ethereum != undefined) {
        let accounts = await window.ethereum.enable();
        console.log("Your connected account is ", accounts);
        this.firstAccount = accounts[0]; 
        console.log("this.firstAccount===", this.firstAccount)
      }
    },

    solMessageHash: async function () {
      const info = this.getContractInfo();
      const rpcUrl = info[0]
      const contractAddress = info[1]
      const contractAbi = info[2]

      const web3 = new Web3(rpcUrl);
 
      const to = this.firstAccount;
      const _amount = web3.utils.toHex(123 * 1e18);
      const _message = "Yidian Metaverse";
      const _nonce = 12;
      
      const myContract = new web3.eth.Contract(contractAbi, contractAddress);
      const hash = await myContract.methods.getMessageHash(to, _amount, _message, _nonce).call();
      console.log("2. Message Hash=", hash);
      this.messageHash = hash;
    },

    MetaMaskSignedMsgHash: async function () {
      let result = await window.ethereum.request({ method: "personal_sign", params: [this.firstAccount, this.messageHash]});
      console.log("Signed Message hash on MetaMask: ", result)
      this.signedMessageHash = result;

      // or

      // const info = this.getContractInfo();
      // const rpcUrl = info[0]
      // const web3 = new Web3(rpcUrl); 
      // const result2 = web3.eth.accounts.sign(this.messageHash, "your private key");
      // console.log("Signed Message hash in web3.js : ", result2)
    },

    solVerify: async function () {
      const info = this.getContractInfo();
      const rpcUrl = info[0]
      const contractAddress = info[1]
      const contractAbi = info[2]

      const web3 = new Web3(rpcUrl);

      const to = this.firstAccount;
      const _amount = web3.utils.toHex(123 * 1e18);
      const _message = "Yidian Metaverse";
      const _nonce = 12;

      const myContract = new web3.eth.Contract(contractAbi, contractAddress);
      const result = await myContract.methods.verify(this.firstAccount, to, _amount, _message, _nonce, this.signedMessageHash).call();
      console.log("The result of verifying signature: ", result);
    },

    // 使用web3.js来生成签名
    web3MessageHash: async function () {
      const info = this.getContractInfo();
      const rpcUrl = info[0]
      let web3 = new Web3(rpcUrl);
      
      const to = this.firstAccount;
      const _amount = 123 * 1e18;
      const _message = "Yidian Metaverse";
      const _nonce = 12;

      let result = web3.utils.soliditySha3(to, _amount, _message, _nonce);
      // let result = web3.utils.soliditySha3({t: 'address', v: to}, {t: 'uint256', v: _amount}, {t: 'string', v: _message}, {t: 'uint256', v: _nonce});
      console.log("Message Hash in web3.js : ", result);
      this.messageHash = result;
    },

    getContractInfo: function () {
      const rpcUrl = "https://rinkeby.infura.io/v3/your-project-id";
      const contractAddress = "0xff0cC28F685b74AB46F724844B49Ff3E71eF65EC";
      const contractAbi = [{"inputs":[{"internalType":"bytes32","name":"_messageHash","type":"bytes32"}],"name":"getEthSignedMessageHash","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"address","name":"_to","type":"address"},{"internalType":"uint256","name":"_amount","type":"uint256"},{"internalType":"string","name":"_message","type":"string"},{"internalType":"uint256","name":"_nonce","type":"uint256"}],"name":"getMessageHash","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"bytes32","name":"_ethSignedMessageHash","type":"bytes32"},{"internalType":"bytes","name":"_signature","type":"bytes"}],"name":"recoverSigner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"bytes","name":"sig","type":"bytes"}],"name":"splitSignature","outputs":[{"internalType":"bytes32","name":"r","type":"bytes32"},{"internalType":"bytes32","name":"s","type":"bytes32"},{"internalType":"uint8","name":"v","type":"uint8"}],"stateMutability":"pure","type":"function"},{"inputs":[{"internalType":"address","name":"_signer","type":"address"},{"internalType":"address","name":"_to","type":"address"},{"internalType":"uint256","name":"_amount","type":"uint256"},{"internalType":"string","name":"_message","type":"string"},{"internalType":"uint256","name":"_nonce","type":"uint256"},{"internalType":"bytes","name":"signature","type":"bytes"}],"name":"verify","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"pure","type":"function"}];
      return [rpcUrl, contractAddress, contractAbi];
    } 

  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
  size: 20px;
}
</style>
