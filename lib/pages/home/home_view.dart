import 'package:epub_image_compressor/pages/about/about_view.dart';
import 'package:epub_image_compressor/pages/compress/compress_view.dart';
import 'package:epub_image_compressor/values/colors.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          ExtendableNavigation(
            onDestinationSelected: _onDestinationSelected,
          ),
          Expanded(
              child: PageView(
            controller: _controller,
            children: const [
              CompressPage(),
              AboutPage(),
            ],
          ))
        ],
      ),
    );
  }

  void _onDestinationSelected(int value) {
    _controller.jumpToPage(value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ExtendableNavigation extends StatefulWidget {
  final ValueChanged<int>? onDestinationSelected;

  const ExtendableNavigation({Key? key, this.onDestinationSelected})
      : super(key: key);

  @override
  State<ExtendableNavigation> createState() => _ExtendableNavigationState();
}

class _ExtendableNavigationState extends State<ExtendableNavigation> {
  int _selectIndex = 0;
  bool _extended = false;

  final List<NavigationRailDestination> destinations = const [
    NavigationRailDestination(icon: Icon(Icons.home), label: Text("首页")),
    NavigationRailDestination(icon: Icon(Icons.podcasts), label: Text("关于")),
  ];

  Widget buildLeading() {
    return GestureDetector(
        onTap: _toggleExtended,
        child: const Icon(
          Icons.menu_open,
          color: AppColors.primary,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.divider,
      padding: const EdgeInsets.only(right: 1.0),
      child: NavigationRail(
        leading: buildLeading(),
        extended: _extended,
        elevation: 1,
        labelType: NavigationRailLabelType.none,
        useIndicator: true,
        unselectedLabelTextStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.normal,
        ),
        selectedLabelTextStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        indicatorColor: AppColors.primary,
        indicatorShape: LinearBorder (
          side: BorderSide(
            color: AppColors.primary,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        backgroundColor: AppColors.surface,
        minWidth: 72,
        minExtendedWidth: 150,
        onDestinationSelected: _onDestinationSelected,
        destinations: destinations,
        selectedIndex: _selectIndex,
        // trailing: const Expanded(
        //   child: Align(
        //     alignment: Alignment.bottomCenter,
        //     child: Padding(
        //       padding: EdgeInsets.only(bottom: 20.0),
        //       child: FlutterLogo(),
        //     ),
        //   ),
        // ),
      ),
    );
  }

  void _onDestinationSelected(int value) {
    _selectIndex = value;
    setState(() {});
    widget.onDestinationSelected?.call(value);
  }

  void _toggleExtended() {
    setState(() {
      _extended = !_extended;
    });
  }
}
