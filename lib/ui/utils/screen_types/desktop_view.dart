import 'package:flutter/material.dart';
import 'package:project_micah/ui/widgets/common/footer/footer.dart';
import 'package:project_micah/ui/widgets/common/header/header.dart';

class DesktopView extends StatelessWidget {
  const DesktopView({
    super.key,
    this.body,
    this.scaffoldKey,
    this.endDrawer,
    this.isLoading = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.breadcrumbs,
    this.onCartTap,
  });

  final Widget? body;
  final Widget? endDrawer;
  final Key? scaffoldKey;
  final bool isLoading;
  final EdgeInsetsGeometry padding;
  final Widget? breadcrumbs;
  final VoidCallback? onCartTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Column(
        children: [
          const Header(
            title: 'MOTORPARTS',
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        if (breadcrumbs != null)
                          Padding(
                            padding: padding,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: breadcrumbs,
                            ),
                          ),
                        Padding(
                          padding: padding,
                          child: body ?? const SizedBox(),
                        ),
                        const Footer(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      endDrawer: endDrawer,
    );
  }
}
