import { Bubble, EncryptionPolicy, assert, bubbleProviders, encryptionPolicies, toDelegateSignFunction, userManagers } from "@bubble-protocol/client";
import { ecdsa } from "@bubble-protocol/crypto";
import { Key, publicKeyToAddress } from "@bubble-protocol/crypto/src/ecdsa";
import { hexToUint8Array, uint8ArrayToHex } from "@bubble-protocol/crypto/src/utils";
import secp256k1 from 'secp256k1';
import { AppError } from "../utils/errors";


export class MemberAdminBubble {

  bubble;

  constructor(config, account, loginKey, delegation) {
    assert.isObject(config, 'config');
    ecdsa.assert.isCompressedPublicKey(config.adminPublicKey, 'config.adminPublicKey');
    ecdsa.assert.isAddress(account, 'account');
    assert.isInstanceOf(loginKey, Key, 'privateKey');
    assert.isObject(delegation, 'delegation');
    const provider = new bubbleProviders.HTTPBubbleProvider(config.bubbleId.provider);
    const signFunction = toDelegateSignFunction(loginKey.signFunction, delegation);
    const encryptionPolicy = new MemberAdminEncryptionPolicy();
    const userManager = new userManagers.MultiUserManager(loginKey, MEMBER_ADMIN_DIR+'/'+account);
    this.bubble = new Bubble(config.bubbleId, provider, signFunction, encryptionPolicy, userManager);
    this.loginKey = loginKey;
  }

  async create(initialAdminPrivateKey) {
    const encryptionPolicy = new MemberAdminEncryptionPolicy(initialAdminPrivateKey);
    this.bubble.setEncryptionPolicy(encryptionPolicy);
    return this.bubble.create({silent: true});
  }

  async initialise() {
    console.trace('initialising member bubble', this.bubble.contentId, this.dataFile);
    await this.bubble.initialise()
      .catch(error => {
        console.debug(error)
        if (error.message.match(/^user metadata file is missing/)) throw new AppError('Your administrator user file is missing from the bubble. Send the following code to the community administrator: "'+this.loginKey.cPublicKey+'"', {code: 'missing-admin-file', publicKey: this.loginKey.cPublicKey});
        else throw error;
      })
    // TODO: get members
  }

  async addAdminMember(publicKey) {
    const address = publicKeyToAddress(publicKey);
    this.bubble.userManager.addUser({publicKey, metadataFile: MEMBER_ADMIN_DIR+'/'+address});
  }

}


const PUBLIC_DIR = "0x8000000000000000000000000000000000000000000000000000000000000001";        // Directory for public files like NFT images
const MEMBER_DIR = "0x8000000000000000000000000000000000000000000000000000000000000002";        // Directory restricted to members only
const MEMBER_ADMIN_DIR = "0x8000000000000000000000000000000000000000000000000000000000000003";  // Directory restricted to member admins only


class MemberAdminEncryptionPolicy extends encryptionPolicies.MultiEncryptionPolicy {
  
  constructor(initialAdminPrivateKey) {
    super(
      new MemberAdminDirEncryptionPolicy(initialAdminPrivateKey),
      new MemberDataEncryptionPolicy()
    );
    if (initialAdminPrivateKey) this.policies[1].setAdminKey(initialAdminPrivateKey);
  }

  async deserialize(data) {
    if (!assert.isObject(data)) return Promise.reject('cannot deserialize MemberAdminEncryptionPolicy: policy data is invalid - expected object');
    if (data.type !== 'MultiEncryptionPolicy') return Promise.reject('cannot deserialize policy: not a MemberAdminEncryptionPolicy');
    if (!assert.isArray(data.policies)) return Promise.reject('cannot deserialize MemberAdminEncryptionPolicy: policies field is missing or invalid');
    if (data.policies.length !== 2) return Promise.reject('cannot deserialize MemberAdminEncryptionPolicy: not enough or too many policies');
    await Promise.all(this.policies.map((policy, index) => policy.deserialize(data.policies[index])));
    this.policies[1].setAdminKey(this.policies[0].privateKey.toString('hex'));
  }

}


class MemberAdminDirEncryptionPolicy extends encryptionPolicies.AESGCMEncryptionPolicy {

  isEncrypted(contentId) {
    return contentId.file === MEMBER_ADMIN_DIR;
  }

}


class MemberDataEncryptionPolicy extends EncryptionPolicy {

  /**
   * @dev set the private admin key (hex string)
   */
  setAdminKey(key) {
    this.adminKey = hexToUint8Array(key);
  }

  isEncrypted(contentId) {
    return contentId.file !== PUBLIC_DIR && contentId.file !== MEMBER_DIR && contentId.file !== MEMBER_ADMIN_DIR; 
  }

  encrypt() {
    throw new Error('MemberDataEncryptionPolicy.encrypt: member data file is read only for member admins');
  }

  decrypt(data) {
    const sharedSecret = uint8ArrayToHex(secp256k1.ecdh(hexToUint8Array(data.publicKey), this.adminKey));
    console.debug('shared secret:', sharedSecret)
    const decryptor = new encryptionPolicies.AESGCMEncryptionPolicy(sharedSecret);
    return decryptor.decrypt(data.data);
  }

  serialize() {
    return Promise.resolve('MemberDataEncryptionPolicy')
  }

  deserialize(data) {
    if (data !== 'MemberDataEncryptionPolicy') return Promise.reject('invalid MemberDataEncryptionPolicy deserialization data')
    return Promise.resolve() 
  }

}