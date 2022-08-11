<template>
  <div class="hello">
    <h1>{{ msg }}</h1> 
    <h1>Sign off-chain & Verify on-chain</h1>

    <div style="border:2px solid blue;">
      <h3>EIP-712 Sign and Verify</h3>
      <ul>
        <li><a href="javascript:;" @click="connectToMetamask" rel="noopener">1. Connect with MetaMask</a></li> 
      </ul>
      <ul>
        <li><a href="javascript:;" @click="hashTypedDataMessage" rel="noopener">2. Hash Typed Data Message</a></li>
      </ul>
      <ul>
        <li><a href="javascript:;" @click="verifyEIP712Signature" rel="noopener">3. Solidity Contract: To verify the signature</a></li>
      </ul>
    </div>

    <br/>

    <div style="border:2px solid purple;">
      <h3>EIP-191 Sign and Verify</h3>
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

  </div>
</template>

<script>

import Web3 from "web3";
const EIP712_EXAMPLE_ABI = require("../assets/abi/eip712example.json")


export default {
  name: 'HelloWorld',
  props: {
    msg: String,
  },
  methods: {    
    
    connectToMetamask: async function () {
      if (window.ethereum != undefined) {
        let accounts = await window.ethereum.enable();
        console.log("Your connected account is ", accounts);
        this.firstAccount = accounts[0]; 
        console.log("this.firstAccount===", this.firstAccount)
      }
    },


    /*********************************** EIP712 Example ****************************************/

    hashTypedDataMessage: async function () {
      // let msgParams = this.getTransferDataToSign() // Test 1 
      // let msgParams = this.getRawTxDataToSign() // Test 2
      let msgParams = this.getTwoStructsDataToSign() // Test 3
      var from = this.firstAccount;
      let signature_ = await window.ethereum.request({ method: 'eth_signTypedData_v4', params: [from, msgParams]});
      console.log("signature: ", signature_)
      this.dataMsg.sign = signature_
    },

    // Test 1
    getTransferDataToSign: function () {
      this.dataMsg = {
        to: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
        amount: 12345
      }
      const msgParams = JSON.stringify({
          domain: {
            chainId: window.ethereum.chainId,
            name: 'Opensea',
            verifyingContract: '0x5FbDB2315678afecb367f032d93F642f64180aa3',
            version: '1.0',
          },
          message: {
            to: this.dataMsg.to,
            amount: this.dataMsg.amount
          },
          primaryType: 'transfer',
          types: {
            EIP712Domain: [
              { name: 'name', type: 'string' },
              { name: 'version', type: 'string' },
              { name: 'chainId', type: 'uint256' },
              { name: 'verifyingContract', type: 'address' },
            ],
            transfer: [
              { name: 'to', type: 'address' },
              { name: 'amount', type: 'uint256' },
            ]
          },
      });
      return msgParams
    },

    // Test 2
    getRawTxDataToSign: function() {
      this.dataMsg = {
        to: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
        value: 12345,
        data: "0x0123456789"
      }
      this.dataTypes = {
          types: {
            EIP712Domain: [
              { name: 'name', type: 'string' },
              { name: 'version', type: 'string' },
              { name: 'chainId', type: 'uint256' },
              { name: 'verifyingContract', type: 'address' },
            ],
            RawTx: [
              { name: 'to', type: 'address' },
              { name: 'value', type: 'uint256' },
              { name: 'data', type: 'bytes' },
            ]
          },
          domain: {
            name: 'Opensea',
            version: '1.0',
            chainId: window.ethereum.chainId,
            verifyingContract: '0x1c85638e118b37167e9298c2268758e058DdfDA0',
          },
          message: {
            to: this.dataMsg.to,
            value: this.dataMsg.value,
            data: this.dataMsg.data
          },
          primaryType: 'RawTx',
      }
      return JSON.stringify(this.dataTypes)
    },

    // Test 3
    getTwoStructsDataToSign: function() { 
      let chainId = window.ethereum.chainId
      if (chainId == null || chainId == undefined) {
          chainId = 31337
      }
      this.dataMsg = {
        version: 1,
        didOwner: "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC",
        initData: {
          alternates: [ "0xBD5924Ad1C6976E9D12F63a86A45c60334777D80"],
          timelocks: [6 * 60 * 60]
        }
      }
      this.typedData = {
          types: {
            EIP712Domain: [
              { name: 'name', type: 'string' },
              { name: 'version', type: 'string' },
              { name: 'chainId', type: 'uint256' },
              { name: 'verifyingContract', type: 'address' },
            ],
            CreateOwnerParam: [
              { name: 'version', type: 'uint256' },
              { name: 'didOwner', type: 'address' },
              { name: 'initData', type: 'InitData' },
            ],
            InitData: [
              { name: 'alternates', type: 'address[]' },
              { name: 'timelocks', type: 'uint256[]' },
            ]
          },
          primaryType: 'CreateOwnerParam',
          domain: {
            name: 'Opensea',
            version: '1.0',
            chainId: chainId,
            verifyingContract: '0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC',
          },
          message: {
            "version": this.dataMsg.version,
            "didOwner": this.dataMsg.didOwner,
            "initData": { 
              "alternates": this.dataMsg.initData.alternates,
              "timelocks": this.dataMsg.initData.timelocks
            }
          },
      }
      return JSON.stringify(this.typedData)
    },

    verifyEIP712Signature: async function () {
      const web3 = new Web3("http://localhost:8545")
      const contractAddress = "0x5f3f1dBD7B74C6B46e8c44f98792A1dAf8d69154"
      const myContract = new web3.eth.Contract(EIP712_EXAMPLE_ABI, contractAddress);
      

      // Test 1
      // const result = await myContract.methods.testTransfer1(this.dataMsg.to, this.dataMsg.amount, this.dataMsg.sign).call();
      

      // Test
      // const result = await myContract.methods.testStructData2([this.dataMsg.to, this.dataMsg.value, this.dataMsg.data], this.dataMsg.sign).call();
      

      // Test 3
      const param = [
        this.dataMsg.version, 
        this.dataMsg.didOwner, 
        [ 
          this.dataMsg.initData.alternates,
          this.dataMsg.initData.timelocks 
        ] 
      ]
      const result = await myContract.methods.testStructData3(param, this.dataMsg.sign).call();
      
      console.log("The result of signer address: ", result);
      console.log(result.toLowerCase() == this.firstAccount.toLowerCase() ? "Verifying Test passed!" : "Verifying Failure!")
    },










    /*********************************** EIP191 Example ****************************************/

    // https://solidity-by-example.org/signature/

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
      const rpcUrl = "https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161";
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
