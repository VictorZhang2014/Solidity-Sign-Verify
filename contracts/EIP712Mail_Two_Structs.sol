// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";

contract EIP712EtherMail {
    
    struct EIP712Domain {
        string  name;
        string  version;
        uint256 chainId;
        address verifyingContract;
    }

    struct Person {
        string name;
        address wallet;
    }

    struct Mail {
        Person from;
        Person to;
        string contents;
    }

    bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    bytes32 constant PERSON_TYPEHASH = keccak256(
        "Person(string name,address wallet)"
    );

    bytes32 constant MAIL_TYPEHASH = keccak256(
        "Mail(Person from,Person to,string contents)Person(string name,address wallet)"
    );

    bytes32 DOMAIN_SEPARATOR;

    constructor () {
        DOMAIN_SEPARATOR = hash(EIP712Domain({
            name: "Ether Mail",
            version: '1',
            chainId: block.chainid,
            // verifyingContract: this
            verifyingContract: 0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC
        }));
    }

    function hash(EIP712Domain memory eip712Domain) public pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH,
            keccak256(bytes(eip712Domain.name)),
            keccak256(bytes(eip712Domain.version)),
            eip712Domain.chainId,
            eip712Domain.verifyingContract
        ));
    }

    function hash(Person memory person) public pure returns (bytes32) {
        return keccak256(abi.encode(
            PERSON_TYPEHASH,
            keccak256(bytes(person.name)),
            person.wallet
        ));
    }

    function hash(Mail memory mail) public pure returns (bytes32) {
        return keccak256(abi.encode(
            MAIL_TYPEHASH,
            hash(mail.from),
            hash(mail.to),
            keccak256(bytes(mail.contents))
        ));
    }

    function verify(Mail memory mail, uint8 v, bytes32 r, bytes32 s) public view returns (address) {
        // Note: we need to use `encodePacked` here instead of `encode`.

        console.log("MAIL_TYPEHASH=========>=========>=========>");
        console.logBytes32(MAIL_TYPEHASH);

        bytes memory encodedData = abi.encode(
            MAIL_TYPEHASH,
            hash(mail.from),
            hash(mail.to),
            keccak256(bytes(mail.contents))
        );
        console.log("encodedData=========>=========>=========>");
        console.logBytes(encodedData);
        
        console.log("keccak256(encodedData)=========>=========>=========>");
        console.logBytes32(keccak256(encodedData));

        console.log("DOMAIN_SEPARATOR)=========>=========>=========>");
        console.logBytes32(DOMAIN_SEPARATOR);


        bytes memory encodedPackedValue = abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            keccak256(encodedData)
            // hash(mail)
        );
        console.log("encodedPackedValue=========>=========>=========>");
        console.logBytes(encodedPackedValue);

        console.log("\x19\x01=========>=========>=========>");
        console.logBytes("\x19\x01");

        bytes32 digest = keccak256(encodedPackedValue);

        console.log("digest)=========>=========>=========>");
        console.logBytes32(digest);

        return ecrecover(digest, v, r, s);
    }

    function verifyByHashedData(bytes32 hashedData, uint8 v, bytes32 r, bytes32 s) public pure returns (address) {
        return ecrecover(hashedData, v, r, s);
    }
    
    function verifySignature(Mail memory mail, bytes memory signature) public view returns(address) {
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, hash(mail)));
        return recoverSigner(digest, signature);
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