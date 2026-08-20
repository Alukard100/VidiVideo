import 'package:flutter/material.dart';

import '../../../../core/dependency/app_services.dart';
import '../../../../core/network/api_client.dart';

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({
    super.key,
  });

  @override
  State<ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState
    extends State<ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();

  final _oldPasswordController =
      TextEditingController();

  final _newPasswordController =
      TextEditingController();

  final _confirmPasswordController =
      TextEditingController();

  bool _isSaving = false;

  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  String? _errorMessage;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await AppServices.profileService.changePassword(
        oldPassword:
            _oldPasswordController.text,
        newPassword:
            _newPasswordController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on ApiException catch (exception) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = exception.message;
      });
    } catch (exception) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Password could not be changed.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _validateNewPassword(String? value) {
    final password = value ?? '';

    if (password.trim().isEmpty) {
      return 'New password is required.';
    }

    if (password.length < 8) {
      return 'Password must contain at least 8 characters.';
    }

    if (!password.contains(
      RegExp(r'[A-Z]'),
    )) {
      return 'Password must contain an uppercase letter.';
    }

    if (!password.contains(
      RegExp(r'[a-z]'),
    )) {
      return 'Password must contain a lowercase letter.';
    }

    if (!password.contains(
      RegExp(r'[0-9]'),
    )) {
      return 'Password must contain a number.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context)
                .viewInsets
                .bottom +
            16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Change password',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _isSaving
                        ? null
                        : () =>
                            Navigator.of(context)
                                .pop(false),
                    icon: const Icon(
                      Icons.close,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller:
                    _oldPasswordController,
                obscureText:
                    !_showOldPassword,
                enabled: !_isSaving,
                decoration: InputDecoration(
                  labelText:
                      'Current password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _showOldPassword =
                            !_showOldPassword;
                      });
                    },
                    icon: Icon(
                      _showOldPassword
                          ? Icons
                              .visibility_off_outlined
                          : Icons
                              .visibility_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  if ((value ?? '')
                      .trim()
                      .isEmpty) {
                    return 'Current password is required.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller:
                    _newPasswordController,
                obscureText:
                    !_showNewPassword,
                enabled: !_isSaving,
                decoration: InputDecoration(
                  labelText: 'New password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _showNewPassword =
                            !_showNewPassword;
                      });
                    },
                    icon: Icon(
                      _showNewPassword
                          ? Icons
                              .visibility_off_outlined
                          : Icons
                              .visibility_outlined,
                    ),
                  ),
                ),
                validator:
                    _validateNewPassword,
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller:
                    _confirmPasswordController,
                obscureText:
                    !_showConfirmPassword,
                enabled: !_isSaving,
                decoration: InputDecoration(
                  labelText:
                      'Confirm new password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword =
                            !_showConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons
                              .visibility_off_outlined
                          : Icons
                              .visibility_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  if ((value ?? '').isEmpty) {
                    return 'Please confirm the new password.';
                  }

                  if (value !=
                      _newPasswordController
                          .text) {
                    return 'Passwords do not match.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFCA5A5),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFB91C1C),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFF991B1B),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              FilledButton(
                onPressed: _isSaving
                    ? null
                    : _changePassword,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Change password',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}