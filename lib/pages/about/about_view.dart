import 'package:epub_image_compressor/utils/app_util.dart';
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
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前版本：',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            SizedBox(height: 8),
            Text('${AppStrings.appVersion}',
                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
            SizedBox(height: 20),
            Text('仓库地址：',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            SizedBox(height: 8),
            Row(
              children: [
                Text('${AppStrings.github}',
                    style:
                        TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
                SizedBox(width: 20),
                OutlinedButton(
                  onPressed: () {
                    AppUtil.openInBrowser(AppStrings.appNewVersion);
                  },
                  child: Text(
                    "查看新版本",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(AppStrings.appDisclaimers,  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            const SizedBox(height: 8),
            Text(AppStrings.appDisclaimer,  style:
            TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
