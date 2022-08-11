<template>
  <div class="hello">
    <h1>{{ msg }}</h1> 
    <a href="javascript:;" @click="testByMetaMask">1.Test with MetaMask >></a>
    <br/>
    <br/>
    <a href="javascript:;" @click="testByPrivateKey">2.Test with Local Private Key >></a>
    <br/>
    <br/>
    <a href="javascript:;" @click="testByContract">3.Verify via Smart Contract >></a>
  </div>
</template>

<script>

import Web3 from "web3";
const EthUtil = require('ethereumjs-util');

import EncodeDataUtil from "./EncodeDataUtil"
const EIP712_MAIL_EXAMPLE_ABI = require("../assets/abi/eip712mail.json")


export default {
  name: 'MailExample',
  props: {
    msg: String,
  },

  mounted() {
    let chainId = window.ethereum.chainId
    if (chainId == null || chainId == undefined) {
        chainId = 31337
    }

    this.typedData = {
        types: {
            EIP712Domain: [
                { name: 'name', type: 'string' },
                { name: 'version', type: 'string' },
                { name: 'chainId', type: 'uint256' },
                { name: 'verifyingContract', type: 'address' },
            ],
            Person: [
                { name: 'name', type: 'string' },
                { name: 'wallet', type: 'address' }
            ],
            Mail: [
                { name: 'from', type: 'Person' },
                { name: 'to', type: 'Person' },
                { name: 'contents', type: 'string' }
            ],
        },
        primaryType: 'Mail',
        domain: {
            name: 'Ether Mail',
            version: '1',
            chainId: chainId,
            verifyingContract: '0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC',
        },
        message: {
            from: {
                name: 'Cow',
                wallet: '0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826',
            },
            to: {
                name: 'Bob',
                wallet: '0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB',
            },
            contents: 'Hello, Bob!',
        },
    }


    // const privateKey = EthUtil.keccakFromString('cow', 256); // to generate a new private key
    const _privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
    this.privateKey = EthUtil.toBuffer(_privateKey)
    this.from = EthUtil.bufferToHex(EthUtil.privateToAddress(this.privateKey));
    console.log("from=", this.from) 
  },

  methods: { 

    testByMetaMask: function() { 
        const encodeUtil = new EncodeDataUtil(this.typedData.types)
        const msgHash = encodeUtil.signHash(this.typedData.domain, this.typedData.primaryType, this.typedData.message)

        var that = this
        const hexMsgHash = JSON.stringify(this.typedData)
        window.ethereum.request({ method: 'eth_signTypedData_v4', params: [this.from, hexMsgHash]}).then((signature_) => {
            const sig = EthUtil.fromRpcSig(signature_)
            that.signature = sig
            that.recoverSigner(msgHash, sig)
        })
    },

    testByPrivateKey: function() {
        const encodeUtil = new EncodeDataUtil(this.typedData.types)
        const msgHash = encodeUtil.signHash(this.typedData.domain, this.typedData.primaryType, this.typedData.message)

        const sig = EthUtil.ecsign(msgHash, this.privateKey);
        this.signature = sig
        this.recoverSigner(msgHash, sig)
    },

    recoverSigner: function(msgHash, sig) {
        const pubKey = EthUtil.ecrecover(msgHash, sig.v, sig.r, sig.s)
        const addrBuf = EthUtil.pubToAddress(pubKey);
        const signer    = EthUtil.bufferToHex(addrBuf);
        console.log("To recover and the signer is ", signer,)
        console.log(signer.toLowerCase() == this.from.toLowerCase() ? "Verified Success!" : "Failed to verify")
    },

    testByContract: async function () {
      const web3 = new Web3("http://localhost:8545")
      const contractAddress = "0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9"
      const myContract = new web3.eth.Contract(EIP712_MAIL_EXAMPLE_ABI, contractAddress);

      const mail = [
        ['Cow', '0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826'],
        ['Bob', '0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB'],
        "Hello, Bob!"
      ]

    //   console.log("v=", this.signature.v)
    //   console.log("r=", EthUtil.bufferToHex(this.signature.r))
    //   console.log("s=", EthUtil.bufferToHex(this.signature.s))

      const result = await myContract.methods.verify(mail, this.signature.v, this.signature.r, this.signature.s).call();
      console.log("1. The signer address is ", result)
      console.log(result.toLowerCase() == this.from.toLowerCase() ? "1. Verifying Success!" : "Failed to verify")

      const sign_ = EthUtil.toRpcSig(this.signature.v, this.signature.r, this.signature.s)
      const result1 = await myContract.methods.verifySignature(mail, sign_).call();
      console.log("2. The signer address is ", result1)
      console.log(result1.toLowerCase() == this.from.toLowerCase() ? "2. Verifying Success!" : "Failed to verify")

    }

  }
}

</script>