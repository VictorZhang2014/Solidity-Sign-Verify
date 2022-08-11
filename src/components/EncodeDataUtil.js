
// doc: https://github.com/ethereum/EIPs/blob/master/assets/eip-712/Example.js

const EthUtil = require('ethereumjs-util');
const abi = require('ethereumjs-abi');


export default class EncodeDataUtil {

    constructor(dataTypes) {
        this.types = dataTypes
    }

    // Recursively finds all the dependencies of a type
    dependencies(primaryType, found = []) {
        if (found.includes(primaryType)) {
            return found;
        }
        if (this.types[primaryType] === undefined) {
            return found;
        }
        found.push(primaryType);
        for (let field of this.types[primaryType]) {
            for (let dep of this.dependencies(field.type, found)) {
                if (!found.includes(dep)) {
                    found.push(dep);
                }
            }
        }
        return found;
    }

    encodeType(primaryType) {
        // Get dependencies primary first, then alphabetical
        let deps = this.dependencies(primaryType);
        deps = deps.filter(t => t != primaryType);
        deps = [primaryType].concat(deps.sort());

        // Format as a string with fields
        let result = '';
        for (let type of deps) {
            result += `${type}(${this.types[type].map(({ name, type }) => `${type} ${name}`).join(',')})`;
        }
        return result;
    }

    typeHash(primaryType) {
        return EthUtil.keccakFromString(this.encodeType(primaryType), 256);
    }

    encodeData(primaryType, data) {
        let encTypes = [];
        let encValues = [];

        // Add typehash
        encTypes.push('bytes32');
        encValues.push(this.typeHash(primaryType));

        // Add field contents
        for (let field of this.types[primaryType]) {
            let value = data[field.name];
            if (field.type == 'string' || field.type == 'bytes') {
                encTypes.push('bytes32');
                value = EthUtil.keccakFromString(value, 256);
                encValues.push(value);
            } else if (this.types[field.type] !== undefined) {
                encTypes.push('bytes32');
                value = EthUtil.keccak256(this.encodeData(field.type, value));
                encValues.push(value);
            } else if (field.type.lastIndexOf(']') === field.type.length - 1) {
                throw 'TODO: Arrays currently unimplemented in encodeData';
            } else {
                encTypes.push(field.type);
                encValues.push(value);
            }
        }
        
        return abi.rawEncode(encTypes, encValues);
    }

    structHash(primaryType, data) {
        return EthUtil.keccak256(this.encodeData(primaryType, data));
    }

    signHash(domain, primaryType, message) {
        const DOMAIN_SEPARATOR = this.structHash('EIP712Domain', domain)
        // console.log("DOMAIN_SEPARATOR=", EthUtil.bufferToHex(DOMAIN_SEPARATOR))
        const dataHash = this.structHash(primaryType, message)
        // console.log("Mail dataHash=", EthUtil.bufferToHex(dataHash))
        return EthUtil.keccak256(
            Buffer.concat([
                Buffer.from('1901', 'hex'), 
                DOMAIN_SEPARATOR,
                dataHash,
            ]),
        );
    }

}
