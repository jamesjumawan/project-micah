import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

class InfoAlertDialog extends StatelessWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const InfoAlertDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              request.title ?? 'Info',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(request.description ?? ''),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => completer(DialogResponse(confirmed: true)),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
