import 'package:get/get.dart';
import '/models/oauth.dart';
import '/models/user.dart';
import '/service/oauth_service.dart';

import 'profile_state.dart';

class ProfileLogic extends GetxController {
  final OauthService authService;
  late final ProfileState state;

  ProfileLogic({required this.authService}) {
    state = ProfileState(authService);
  }

  Future<void> logout() async {
    await authService.logout();
  }

  Future<void> mockLogin() async {
    final oauth = Oauth(
      access_token: 'mock-token',
      username: 'Tin User',
      user_id: '10001',
      refresh_token: 'refresh-mock',
    );
    await authService.login(oauth);
    authService.user.value = User(username: oauth.username);
  }
}
