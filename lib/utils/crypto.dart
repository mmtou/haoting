import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import "package:pointycastle/export.dart";

class Crypto {
  static const modulus =
      '00e0b509f6259df8642dbc35662901477df22677ec152b5ff68ace615bb7b725152b3ab17a876aea8a5aa76d2e417629ec4ee341f56135fccf695280104e0312ecbda92557c93870114af6c9d05c4f7f0c3685b7a46bee255932575cce10b424d813cfe4875d3e82047b97ddef52741d546b8e289dc6935b3ece0462db0a22b8e7';
  static const nonce = '0CoJUm6Qyw8W8jud';
  static const pubKey = '010001';

  static Map crypto(param) {
    var text = json.encode(param);
    var secKey = _createSecretKey(16);
    var encText = _aesEncrypt(_aesEncrypt(text, nonce), secKey);
//    const encSecKey = rsaEncrypt(secKey, pubKey, modulus);
    const encSecKey =
        'd51ae5a328e6875b7ad2a6a72eced5fa84cc917a727e21d41b0789177ffcf191a865b1ff64b42072637fcef63642d0b1aff17ef2395112260cbb33291e993dc5b65bd403c33fa5c68b49ae32be8abefeaa1fe3f18c8befc5ca9339061fc0fbf3f743eea3e887a677cee834d731903ebfd1e1a9ad2ff4b16d91a3d047e01a5fd9';
    return {'params': encText, 'encSecKey': encSecKey};
  }

  static _createSecretKey(size) {
    const keys =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    var key = "";
    for (var i = 0; i < size; i++) {
      var pos = (Random().nextDouble() * keys.length).floor();
      key = key + keys.split('')[pos];
    }
    return key;
  }

  static _aesEncrypt(text, secKey) {
    var key = utf8.encode(secKey);
    var iv = utf8.encode('0102030405060708');
    CipherParameters params = new PaddedBlockCipherParameters(
        new ParametersWithIV(new KeyParameter(key), iv), null);

//    PaddedBlockCipherImpl cipherImpl = new PaddedBlockCipherImpl(
//        new PKCS7Padding(), new CBCBlockCipher(new AESFastEngine()));
////    cipherImpl.init(true, params);
//    BlockCipher encryptionCipher = new PaddedBlockCipher("AES/CBC/PKCS7");
//    encryptionCipher.init(true, params);

    BlockCipher encryptionCipher = new BlockCipher("CBC");
    encryptionCipher.init(true, params);
    Uint8List encrypted = encryptionCipher.process(utf8.encode(text));
    String encryptedStr = base64.encode(utf8.encode(hex.encode(encrypted)));
    print("Encrypted: \n" + encryptedStr);
    return encryptedStr;
  }

//  rsaEncrypt(text, pubKey, modulus) {
//    var _text = text.split('').reverse().join('');
//    var biText = int.parse(_text, radix: 16).toRadixString(2),
//        biEx = bigInt(pubKey, 16),
//        biMod = bigInt(modulus, 16),
//        biRet = biText.modPow(biEx, biMod);
//    return zfill(biRet.toString(16), 256);
//  }

  _zfill(str, size) {
    while (str.length < size) str = "0" + str;
    return str;
  }
}
