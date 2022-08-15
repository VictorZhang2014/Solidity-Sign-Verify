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
const EIP712_MAIL_EXAMPLE_ABI = require("../assets/abi/eip712mail_two_structs.json")


export default {
  name: 'MailExample',
  props: {
    msg: String,
  },

  mounted() {
    let chainId = window.ethereum.chainId
    if (chainId == null || chainId == undefined) {
        chainId = 223344 //31337
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
            ]
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
                wallet: '0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826'
            },
            to: {
                name: 'Bob',
                wallet: '0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB'
            },
            contents: 'Hello, Bob!',
        },
    }

    // this.$privateKey = EthUtil.keccakFromString('cow', 256); // to generate a new private key
    const _privateKey = "Your private key"
    this.privateKey = EthUtil.toBuffer(_privateKey)
    this.from = EthUtil.bufferToHex(EthUtil.privateToAddress(this.privateKey));
    console.log("from=", this.from) 
  },

  methods: { 

    testByMetaMask: function() { 
        const encodeUtil = new EncodeDataUtil(this.typedData.types)
        const msgHash = encodeUtil.signHash(this.typedData.domain, this.typedData.primaryType, this.typedData.message)


        // const web3 = new Web3("http://localhost:8545")
  
        // const DOMAIN_HASH = web3.utils.keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
        // const DOMAIN_SEPARATOR = web3.utils.keccak256(
        //   web3.eth.abi.encodeParameters(
        //     ["bytes32","bytes32","bytes32","uint256","address"], 
        //     [DOMAIN_HASH, web3.utils.keccak256("Ether Mail"), web3.utils.keccak256("1"), 31337, '0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC']
        //   )
        // )
        // console.log("DOMAIN_SEPARATOR=", DOMAIN_SEPARATOR)


        // const HOME_TYPE_HASH = web3.utils.keccak256("HomeAddress(string home,string phone,uint256 age)")
        // const HOME_HASH_FROM = web3.utils.keccak256(
        //   web3.eth.abi.encodeParameters(
        //     ["bytes32", "bytes32", "bytes32", "uint256"], 
        //     [HOME_TYPE_HASH, web3.utils.keccak256("The USA"),web3.utils.keccak256("123456"), 20]
        //   )
        // )
        // const HOME_HASH_TO = web3.utils.keccak256(
        //   web3.eth.abi.encodeParameters(
        //     ["bytes32", "bytes32", "bytes32", "uint256"], 
        //     [HOME_TYPE_HASH, web3.utils.keccak256("United Kindom"),web3.utils.keccak256("098765"), 22]
        //   )
        // )


        // const PERSON_TYPE_HASH = web3.utils.keccak256("Person(string name,address wallet,HomeAddress addr)HomeAddress(string home,string phone,uint256 age)")
        // const PERSON_HASH_FROM = web3.utils.keccak256(
        //   web3.eth.abi.encodeParameters(
        //     ["bytes32", "bytes32", "address", "bytes32"], 
        //     [PERSON_TYPE_HASH, web3.utils.keccak256("Cow"), "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826", HOME_HASH_FROM]
        //   )
        // )
        // const PERSON_HASH_TO = web3.utils.keccak256(
        //   web3.eth.abi.encodeParameters(
        //     ["bytes32", "bytes32", "address", "bytes32"], 
        //     [PERSON_TYPE_HASH, web3.utils.keccak256("Bob"), "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB", HOME_HASH_TO]
        //   )
        // )


        // const MAIL_TYPE_HASH = web3.utils.keccak256("Mail(Person from,Person to,string contents)Person(string name,address wallet,HomeAddress addr)HomeAddress(string home,string phone,uint256 age)")
        // const MAIL_HASH = web3.utils.keccak256(
        //   web3.eth.abi.encodeParameters(
        //     ["bytes32", "bytes32", "bytes32", "bytes32"], 
        //     [MAIL_TYPE_HASH, PERSON_HASH_FROM, PERSON_HASH_TO, web3.utils.keccak256('Hello, Bob!')]
        //   )
        // )
        // console.log("MAIL_HASH=", MAIL_HASH)


        // const beforeDigest = web3.utils.encodePacked(
        //     {v: "0x1901", t: "bytes"},
        //     {v: DOMAIN_SEPARATOR, t: "bytes32"},
        //     {v: MAIL_HASH, t: "bytes32"}
        //   )
        // console.log("beforeDigest=", beforeDigest)
        // const digest = web3.utils.keccak256(beforeDigest)
        // console.log("digest=", digest)
        // this.signature_digest = digest

        // // 签名
        // const msgHash0 = EthUtil.toBuffer(digest)
        // const sig0 = EthUtil.ecsign(msgHash0, this.privateKey);
        // this.signature_sig0 = sig0
        // // 验证
        // this.recoverSigner(msgHash0, sig0)



        var that = this
        const hexMsgHash = JSON.stringify(this.typedData)
        window.ethereum.request({ method: 'eth_signTypedData_v4', params: [this.from, hexMsgHash]}).then((signature_) => {
            const sig = EthUtil.fromRpcSig(signature_)
            that.signature = sig
            console.log("MetaMask sign= ", signature_)
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
        const pubKey    = EthUtil.ecrecover(msgHash, sig.v, sig.r, sig.s)
        const addrBuf   = EthUtil.pubToAddress(pubKey);
        const signer    = EthUtil.bufferToHex(addrBuf);
        console.log("\r\n\r\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        console.log("To recover and the signer is ", signer,)
        alert("recoverSigner => " + signer)
        console.log(signer.toLowerCase() == this.from.toLowerCase() ? "Verified Success!" : "Failed to verify")
    },

    testByContract: async function () {
      // const web3 = new Web3("http://localhost:8545")
      const web3 = new Web3("https://geth.mm.comeonbtc.com:8443")
      const contractAddress = "0xD42912755319665397FF090fBB63B1a31aE87Cee"
      const myContract = new web3.eth.Contract(EIP712_MAIL_EXAMPLE_ABI, contractAddress);

      const mail = [
        ['Cow', '0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826' ],
        ['Bob', '0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB' ],
        "Hello, Bob!"
      ]

    //   console.log("v=", this.signature.v)
    //   console.log("r=", EthUtil.bufferToHex(this.signature.r))
    //   console.log("s=", EthUtil.bufferToHex(this.signature.s))

      // this.signature = this.signature_sig0
      const result = await myContract.methods.verify(mail, this.signature.v, this.signature.r, this.signature.s).call();
      console.log("\r\n\r\n  1. The signer address is ", result)
      alert("1. The signer address is " + result) 
      console.log(result.toLowerCase() == this.from.toLowerCase() ? "1. Verifying Success!" : "Failed to verify")


      const sign_ = EthUtil.toRpcSig(this.signature.v, this.signature.r, this.signature.s)
      const result1 = await myContract.methods.verifySignature(mail, sign_).call();
      console.log("\r\n\r\n  2. The signer address is ", result1)
      alert("2. The signer address is " + result1)
      console.log(result1.toLowerCase() == this.from.toLowerCase() ? "2. Verifying Success!" : "Failed to verify")


      const encodeUtil = new EncodeDataUtil(this.typedData.types)
      const msgHash = encodeUtil.signHash(this.typedData.domain, this.typedData.primaryType, this.typedData.message)
      const result3 = await myContract.methods.verifyByHashedData(msgHash, this.signature.v, this.signature.r, this.signature.s).call();
      console.log("\r\n\r\n  3. The signer address is ", result3)
      alert("3. The signer address is " + result3)
      console.log(result3.toLowerCase() == this.from.toLowerCase() ? "3. Verifying Success!" : "Failed to verify")

    }

  }
}

</script>