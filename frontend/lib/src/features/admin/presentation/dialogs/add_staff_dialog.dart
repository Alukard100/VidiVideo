import 'package:flutter/material.dart';

import '../../../../core/dependency/app_services.dart';
import '../../../../core/network/api_client.dart';

class AddStaffDialog extends StatefulWidget {
  const AddStaffDialog({
    required this.isSuperAdmin,
    super.key,
  });

  final bool isSuperAdmin;

  @override
  State<AddStaffDialog> createState() =>
      _AddStaffDialogState();
}

class _AddStaffDialogState
    extends State<AddStaffDialog> {
  final _formKey = GlobalKey<FormState>();

  final _userNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _role = 'Moderator';

  bool _isSaving = false;

  @override
  void dispose() {
    _userNameController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await AppServices.adminStaffService.createStaff(
        userName: _userNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.trim(),
        role: _role,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } on ApiException catch (exception) {
      _showMessage(
        'Unable to add team member '
        '(${exception.statusCode}): '
        '${exception.message}',
      );
    } catch (_) {
      _showMessage(
        'Unable to add team member.',
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
      title: const Text('Add Team Member'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _userNameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().length < 5) {
                      return 'Username must contain at least 5 characters.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Display name is required.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim();

                    if (!text.contains('@')) {
                      return 'Enter a valid email.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                  validator: (value) {
                    if ((value ?? '').isEmpty) {
                      return 'Password is required.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  initialValue: _role,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'Moderator',
                      child: Text('Moderator'),
                    ),
                    if (widget.isSuperAdmin)
                      const DropdownMenuItem(
                        value: 'Admin',
                        child: Text('Admin'),
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
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.person_add_outlined),
          label: const Text('Add Member'),
        ),
      ],
    );
  }
}