import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'example_viewmodel.dart';

class ExampleViewTablet extends ViewModelWidget<ExampleViewModel> {
  const ExampleViewTablet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ExampleViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(title: Text(viewModel.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tablet View',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            if (viewModel.isBusy)
              const CircularProgressIndicator()
            else
              const Text('Content goes here'),
          ],
        ),
      ),
    );
  }
}
