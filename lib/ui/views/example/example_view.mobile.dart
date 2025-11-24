import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'example_viewmodel.dart';

class ExampleViewMobile extends ViewModelWidget<ExampleViewModel> {
  const ExampleViewMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ExampleViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(title: Text(viewModel.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Mobile View',
              style: Theme.of(context).textTheme.headlineMedium,
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
