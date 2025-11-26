import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '/routers/routes.dart';
import '/values/values.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('页面不存在')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            const Text('找不到页面'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(AppRoutes.compress),
              child: Text('返回${AppStrings.home}'),
            ),
          ],
        ),
      ),
    );
  }
}
