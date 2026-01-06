import 'package:flutter/material.dart';
import 'package:project_micah/ui/widgets/common/footer/footer.dart';
import 'package:project_micah/ui/widgets/common/header/header.dart';

class TabletView extends StatelessWidget {
  const TabletView({
    super.key,
    this.body,
    this.scaffoldKey,
    this.endDrawer,
    this.isLoading = false,
    this.isScrollable = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.breadcrumbs,
    this.onCartTap,
  });

  final Widget? body;
  final Widget? endDrawer;
  final Key? scaffoldKey;
  final bool isLoading;
  final bool isScrollable;
  final EdgeInsetsGeometry padding;
  final Widget? breadcrumbs;
  final VoidCallback? onCartTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : isScrollable
                    ? SingleChildScrollView(
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
                      )
                    : Column(
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
                        ],
                      ),
          ),
        ],
      ),
      endDrawer: endDrawer,
    );
  }
}
