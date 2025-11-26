import 'dart:convert';

import 'package:get/get.dart';

import '../models/models.dart';
import '../utils/utils.dart';

class OauthService extends GetxService {
  final oauth = Oauth().obs;
  final user = User().obs;
  final isLogin = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPersistedSession();
  }

  Future<void> _loadPersistedSession() async {
    try {
      await PrefsUtil.ensureInitialized();
      final oauthJson = PrefsUtil().oauth;
      if (oauthJson.isEmpty) return;

      oauth.value = Oauth.fromJson(jsonDecode(oauthJson));
      _updateLoginStatus(oauth.value);
    } catch (e) {
      Get.log('Error decoding OAuth data: $e', isError: true);
    }
  }

  void _updateLoginStatus(Oauth? oauthNew) {
    if (oauthNew == null) {
      isLogin.value = false;
      return;
    }

    if (oauthNew.access_token != null) {
      oauth.value = oauthNew;
      isLogin.value = true;
    } else {
      isLogin.value = false;
    }
  }

  Future<void> login(Oauth oauth) async {
    try {
      _updateLoginStatus(oauth);
      await PrefsUtil().setOauth(jsonEncode(oauth));
    } catch (e) {
      Get.log('Error saving OAuth data: $e', isError: true);
    }
  }

  Future<void> logout() async {
    try {
      _updateLoginStatus(null);
      await PrefsUtil().setOauth('');
    } catch (e) {
      Get.log('Error clearing OAuth data: $e', isError: true);
    }
  }
}
