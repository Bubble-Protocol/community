import { Bubble, bubbleProviders, encryptionPolicies, toFileId } from "@bubble-protocol/client";
import { ecdsa } from "@bubble-protocol/crypto";
import { assert } from "@bubble-protocol/client";
import { hexToUint8Array, uint8ArrayToHex } from "@bubble-protocol/crypto/src/utils";
import secp256k1 from 'secp256k1';
import { Key } from "@bubble-protocol/crypto/src/ecdsa";

export class MemberBubble {

  memberData;
  dataFile;
  bubble;

  constructor(config, account, loginKey) {
    console.debug('constructing MemberBubble', config, account, loginKey);
    assert.isObject(config, 'config');
    ecdsa.assert.isCompressedPublicKey(config.adminPublicKey, 'config.adminPublicKey');
    ecdsa.assert.isAddress(account, 'account');
    assert.isInstanceOf(loginKey, Key, 'privateKey');
    const provider = new bubbleProviders.HTTPBubbleProvider(config.bubbleId.provider);
    this.dataFile = toFileId(account);
    let encryptionPolicy = new MemberEncryptionPolicy(config.adminPublicKey, loginKey, this.dataFile);
    this.bubble = new Bubble(config.bubbleId, provider, loginKey.signFunction, encryptionPolicy);
  }

  async initialise() {
    console.trace('initialising member bubble', this.bubble.contentId, this.dataFile);
    await this.bubble.initialise();
    await this.getData();
  }

  async getData() {
    console.trace('reading member data from bubble');
    if (!this.memberData) {
      const json = await this.bubble.read(toFileId(this.dataFile), {silent: true});
      if (json) this.memberData = JSON.parse(json);
      console.trace('member data:', this.memberData);
    }
    return this.memberData;
  }
  
  async setData(memberData) {
    console.trace('writing member data to bubble', memberData);
    await this.bubble.write(this.dataFile, JSON.stringify(memberData));
    this.memberData = memberData;
  }

  async deleteData() {
    console.trace('deleting member data from bubble');
    await this.bubble.delete(this.dataFile, {silent: true});
    this.memberData = undefined;
    console.log('member data deleted from bubble');
  }

}


class MemberEncryptionPolicy extends encryptionPolicies.AESGCMEncryptionPolicy {
  
  constructor(publicKey, key, dataFile) {
    const sharedSecret = uint8ArrayToHex(secp256k1.ecdh(hexToUint8Array(publicKey), hexToUint8Array(key.privateKey)));
    console.debug('shared secret:', sharedSecret)
    super(sharedSecret);
    this.publicKey = key.cPublicKey;
    this.dataFile = dataFile.toLowerCase();
  }

  isEncrypted(contentId) {
    return contentId.file.toLowerCase() == this.dataFile;
  }

  encrypt(data) {
    const publicKey = this.publicKey;
    return super.encrypt(data)
      .then(encryptedData => {
        return JSON.stringify({
          publicKey: publicKey,
          data: encryptedData
        });
      });
  }

  decrypt(json) {
    let data;
    try {
      data = JSON.parse(json);
    }
    catch(error) {
      console.warn('MemberEncryptionPolicy.decrypt: data not valid json', error);
      return Promise.resolve(Buffer.from(''));
    }
    if (!data || !data.data) {
      console.warn('MemberEncryptionPolicy.decrypt: data is invalid');
      return Promise.resolve(Buffer.from(''));
    }
    return super.decrypt(data.data)
    .catch(error => {
      console.warn('MemberEncryptionPolicy.decrypt: data encryption is invalid', error);
    })
  }

}