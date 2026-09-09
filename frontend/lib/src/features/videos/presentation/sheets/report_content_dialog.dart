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
  final _formKey = GlobalKey<FormState>();
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
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Reason',
          ),
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'Please enter a reason.';
            }

            return null;
          },
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
            if (!(_formKey.currentState
                    ?.validate() ??
                false)) {
              return;
            }

            Navigator.of(context).pop(
              _controller.text.trim(),
            );
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
