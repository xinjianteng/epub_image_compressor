import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/service/oauth_service.dart';
import '/values/values.dart';

import 'profile_logic.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<OauthService>();
    final ProfileLogic logic = Get.put(ProfileLogic(authService: authService));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    child: const Icon(Icons.person_outline),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authService.user.value.username ?? '访客',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        authService.isLogin.value ? '已登录' : '未登录',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed:
                    authService.isLogin.value ? logic.logout : logic.mockLogin,
                child: Text(
                  authService.isLogin.value
                      ? AppStrings.logout
                      : AppStrings.login,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
