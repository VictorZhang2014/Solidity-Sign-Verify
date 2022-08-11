// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract EIP712EtherMail {
    
    struct EIP712Domain {
        string  name;
        string  version;
        uint256 chainId;
        address verifyingContract;
    }

    struct HomeAddress {
        string home;
        string phone;
        uint256 age;
    }

    struct Person {
        string name;
        address wallet;
        HomeAddress addr;
    }

    struct Mail {
        Person from;
        Person to;
        string contents;
    }

    bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
    );

    bytes32 constant HOME_ADDRESS_TYPEHASH = keccak256(
        "HomeAddress(string home,string phone,uint256 age)"
    );

    bytes32 constant PERSON_TYPEHASH = keccak256(
        "Person(string name,address wallet,HomeAddress addr)HomeAddress(string home,string phone,uint256 age)"
    );

    bytes32 constant MAIL_TYPEHASH = keccak256(
        "Mail(Person from,Person to,string contents)Person(string name,address wallet,HomeAddress addr)HomeAddress(string home,string phone,uint256 age)"
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

    function hash(HomeAddress memory addr) public pure returns (bytes32) {
        return keccak256(abi.encode(
            HOME_ADDRESS_TYPEHASH,
            keccak256(bytes(addr.home)),
            keccak256(bytes(addr.phone)),
            addr.age
        ));
    }

    function hash(Person memory person) public pure returns (bytes32) {
        return keccak256(abi.encode(
            PERSON_TYPEHASH,
            keccak256(bytes(person.name)),
            person.wallet,
            hash(person.addr)
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
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            hash(mail)
        ));
        return ecrecover(digest, v, r, s);
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

    // function test(address signer) public view returns (bool) {
    //     // Example signed message
    //     Mail memory mail = Mail({
    //         from: Person({
    //             name: "Cow",
    //             wallet: 0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826,
    //             addr: Address({
    //                 home: "The USA",
    //                 phone: "123456",
    //                 age: 20
    //             })
    //         }),
    //         to: Person({
    //             name: "Bob",
    //             wallet: 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB,
    //             addr: Address({
    //                 home: "United Kindom",
    //                 phone: "098765",
    //                 age: 22
    //             })
    //         }),
    //         contents: "Hello, Bob!"
    //     });
    //     uint8 v = 28;
    //     bytes32 r = 0x4355c47d63924e8a72e509b65029052eb6c299d53a04e167c5775fd466751c9d;
    //     bytes32 s = 0x07299936d304c153f6443dfa05f40ff007d72911b6f72307f996231605b91562;
        
    //     assert(DOMAIN_SEPARATOR == 0xf2cee375fa42b42143804025fc449deafd50cc031ca257e0b194a650a912090f);
    //     assert(hash(mail) == 0xc52c0ee5d84264471806290a3f2c4cecfc5490626bf912d01f240d7a274b371e);
    //     assert(verify(mail, v, r, s) == signer);
    //     return true;
    // }
}