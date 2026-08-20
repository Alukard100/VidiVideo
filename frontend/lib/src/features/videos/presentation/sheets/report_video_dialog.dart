import 'package:flutter/material.dart';

class ReportVideoDialog extends StatefulWidget {
  const ReportVideoDialog({
    super.key,
  });

  @override
  State<ReportVideoDialog> createState() =>
      _ReportVideoDialogState();
}

class _ReportVideoDialogState
    extends State<ReportVideoDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report video'),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Reason',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context)
                  .pop(_controller.text),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}