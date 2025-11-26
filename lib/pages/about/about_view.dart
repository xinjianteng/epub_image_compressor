import 'package:flutter/material.dart';

import '/values/values.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.appName, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('版本：${AppStrings.appVersion}',
                style: theme.textTheme.bodyMedium),
            Text('作者：${AppStrings.appAuthor}',
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Text(
              AppStrings.appTagline,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.appDisclaimers,
                style: theme.textTheme.bodyMedium
            ),
            Text(
              AppStrings.appDisclaimer,
                style: theme.textTheme.bodyMedium
            )
          ],
        ),
      ),
    );
  }
}
