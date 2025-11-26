import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:get/get.dart';

/**
 * 加密工具类
 * 提供常用的加密算法实现，包括MD5和AES加密
 */
class EncryptUtils {
  /**
   * MD5加密函数
   * 将输入的字符串进行MD5哈希运算，返回大写的十六进制字符串
   *
   * @param str 需要加密的原始字符串
   * @return 返回MD5加密后的大写十六进制字符串
   */
  static String encryptMd5(String str) {
    //转化字符串
    final utf = utf8.encode(str);
    //加密
    final digest = md5.convert(utf);
    final encryptStr = digest.toString();
    return encryptStr.toUpperCase();
  }

  /**
   * AES加密函数
   * 使用AES算法对指定内容进行加密，采用CBC模式
   *
   * @param content 被加密的数据内容
   * @param keyStr 加密使用的密钥字符串
   * @param ivStr 初始化向量字符串
   * @return 返回AES加密后的base64编码字符串
   */
  static String encryptAES(String content, String keyStr, String ivStr) {
    Get.log("AES加密前的文本:$content");
    final plainText = content;
    // final key = encrypt.Key.fromUtf8(keyStr);
    final key = encrypt.Key.fromUtf8(keyStr);

    final iv = encrypt.IV.fromUtf8(ivStr);
    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final encryptStr = encrypted.base64;
    Get.log("AES加密后的文本:$encryptStr");
    return encryptStr;
  }
}
