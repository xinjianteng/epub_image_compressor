import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/utils/prefs_util.dart';
import '/values/values.dart';
import '/routers/routes.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  Future<void> _clearLogin() async {
    await PrefsUtil().setOauth('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.setting),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('跟随系统暗色模式'),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (_) {},
          ),
          ListTile(
            title: const Text('清除本地会话数据'),
            trailing: const Icon(Icons.cleaning_services_outlined),
            onTap: _clearLogin,
          ),
          ListTile(
            title: const Text('关于'),
            subtitle: Text('版本 ${AppStrings.appVersion}'),
            onTap: () => Get.toNamed(AppRoutes.aboutApp),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '在这里管理个性化偏好：主题、通知、缓存等。',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
