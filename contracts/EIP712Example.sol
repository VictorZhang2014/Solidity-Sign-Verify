// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract EIP712Example {

    bytes32 public constant EIP712DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    // Test 1
    bytes32 public constant TRANSFER_TO_TYPEHASH = keccak256(
        "transfer(address to,uint256 amount)"
    );

    // Test 2
    struct RawTx {
        address to;
        uint256 value;
        bytes data;
    }
    bytes32 public constant RAW_TX_TYPEHASH = keccak256("RawTx(address to,uint256 value,bytes data)");

    // Test 3
    struct CreateOwnerParam {
        uint256 version;
        address didOwner;
        InitData initData;
    }
    // struct InitData {
    //     address[] alternate;
    //     uint256[] timelock;
    // }
    struct InitData {
        AlternateOwner[] alternates;
        string demo;
    }
    struct AlternateOwner {
        address owner;
        uint256 timelock;
    }
    bytes32 public constant CREATE_OWNER_PARAM_TYPEHASH = keccak256("CreateOwnerParam(uint256 version,address didOwner,InitData initData)InitData(AlternateOwner[] alternates,string demo)AlternateOwner(address owner,uint256 timelock)");
    bytes32 public constant INIT_DATA_TYPEHASH = keccak256("InitData(AlternateOwner[] alternates,string demo)AlternateOwner(address owner,uint256 timelock)");

    bytes32 DOMAIN_SEPARATOR;

    constructor () {
        uint chainId = block.chainid;
        DOMAIN_SEPARATOR = keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH,
            keccak256(bytes("Opensea")),
            keccak256(bytes("1.0")),
            chainId,
            0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC
        ));
    }

    function testTransfer1(address to, uint256 amount, bytes memory signature) public view returns (address) {
        bytes32 dataHashStruct = keccak256(abi.encode(TRANSFER_TO_TYPEHASH, to, amount));
        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, dataHashStruct));
        address signer = recoverSigner(hash, signature);
        return signer;
    }

    function testStructData2(RawTx memory _raw, bytes memory signature) public view returns (address) {
        bytes32 dataHashStruct = keccak256(abi.encode(RAW_TX_TYPEHASH, _raw.to, _raw.value, keccak256(_raw.data)));
        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, dataHashStruct));
        address signer = recoverSigner(hash, signature);
        return signer;
    }

    function testStructData3(CreateOwnerParam memory param, bytes memory signature) public view returns (address) {
        // bytes32 initData_ = keccak256(abi.encode(
        //     INIT_DATA_TYPEHASH, 
        //     keccak256(abi.encodePacked(param.initData.alternate)),
        //     keccak256(abi.encodePacked(param.initData.timelock))
        // ));

        bytes32[] memory datalist = new bytes32[](param.initData.alternates.length);
        for (uint i = 0; i < param.initData.alternates.length; i++) {
            AlternateOwner memory ao = param.initData.alternates[i];
            datalist[i] = keccak256(abi.encode(keccake256("AlternateOwner(address owner,uint256 timelock)"), ao.owner, ao.timelock));
        }
        bytes32 initData_ = keccak256(abi.encode(
            INIT_DATA_TYPEHASH, 
            keccak256(abi.encodePacked(datalist)),
            keccak256(bytes(param.initData.demo))
        ));

        bytes32 dataHashStruct = keccak256(abi.encode(CREATE_OWNER_PARAM_TYPEHASH, param.version, param.didOwner, initData_));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, dataHashStruct));
        address signer = recoverSigner(digest, signature);
        return signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");
        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
        // implicitly return (r, s, v)
    }


}