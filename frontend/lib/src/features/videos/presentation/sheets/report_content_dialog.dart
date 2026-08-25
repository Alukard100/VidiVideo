import 'package:flutter/material.dart';

class ReportContentDialog extends StatefulWidget {
  const ReportContentDialog({
    required this.title,
    super.key,
  });

  final String title;

  @override
  State<ReportContentDialog> createState() =>
      _ReportContentDialogState();
}

class _ReportContentDialogState
    extends State<ReportContentDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
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
          onPressed: () {
            final reason =
                _controller.text.trim();

            if (reason.isEmpty) {
              return;
            }

            Navigator.of(context).pop(reason);
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}