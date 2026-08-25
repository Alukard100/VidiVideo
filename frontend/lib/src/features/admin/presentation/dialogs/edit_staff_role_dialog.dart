import 'package:flutter/material.dart';

import '../../../../core/dependency/app_services.dart';
import '../../../../core/network/api_client.dart';
import '../../models/admin_staff_member.dart';

class EditStaffRoleDialog extends StatefulWidget {
  const EditStaffRoleDialog({
    required this.member,
    super.key,
  });

  final AdminStaffMember member;

  @override
  State<EditStaffRoleDialog> createState() =>
      _EditStaffRoleDialogState();
}

class _EditStaffRoleDialogState
    extends State<EditStaffRoleDialog> {
  late String _role;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _role = widget.member.role == 'Admin'
        ? 'Admin'
        : 'Moderator';
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await AppServices.adminStaffService.updateRole(
        targetId: widget.member.id,
        role: _role,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } on ApiException catch (exception) {
      _showMessage(
        'Unable to change role '
        '(${exception.statusCode}): '
        '${exception.message}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Team Member'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.member.displayName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              widget.member.email,
              style: const TextStyle(
                color: Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: const InputDecoration(
                labelText: 'Role',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Admin',
                  child: Text('Admin'),
                ),
                DropdownMenuItem(
                  value: 'Moderator',
                  child: Text('Moderator'),
                ),
              ],
              onChanged: _isSaving
                  ? null
                  : (value) {
                      if (value == null) return;

                      setState(() {
                        _role = value;
                      });
                    },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}