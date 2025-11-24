import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'example_viewmodel.dart';

class ExampleViewDesktop extends ViewModelWidget<ExampleViewModel> {
  const ExampleViewDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ExampleViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(title: Text(viewModel.title)),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Desktop View',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 16),
              if (viewModel.isBusy)
                const CircularProgressIndicator()
              else
                const Text('Content goes here'),
            ],
          ),
        ),
      ),
    );
  }
}
