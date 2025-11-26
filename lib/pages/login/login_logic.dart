import 'package:get/get.dart';
import '/models/oauth.dart';
import '/models/user.dart';
import '/routers/routes.dart';
import '/service/oauth_service.dart';

import 'login_state.dart';

class LoginLogic extends GetxController {
  final LoginState state = LoginState();
  final OauthService authService;

  LoginLogic({required this.authService});

  Future<void> mockLogin() async {
    final oauth = Oauth(
      access_token: 'mock-token',
      refresh_token: 'refresh-mock',
      username: 'Tin User',
      user_id: '10001',
    );
    await authService.login(oauth);
    authService.user.value = User(username: oauth.username);
    Get.offAllNamed(AppRoutes.compress);
  }
}
