import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

class NoticeSheet extends StatelessWidget {
  final SheetRequest request;
  final Function(SheetResponse) completer;

  const NoticeSheet({Key? key, required this.request, required this.completer})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            request.title ?? 'Notice',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(request.description ?? ''),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => completer(SheetResponse(confirmed: true)),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
