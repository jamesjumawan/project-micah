import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:project_micah/ui/widgets/common/loading/cog_loader.dart';

import 'startup_viewmodel.dart';

class StartupViewDesktop extends ViewModelWidget<StartupViewModel> {
  const StartupViewDesktop({super.key});

  @override
  Widget build(BuildContext context, StartupViewModel viewModel) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Project Micah',
              style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            const CogLoader(),
          ],
        ),
      ),
    );
  }
}
