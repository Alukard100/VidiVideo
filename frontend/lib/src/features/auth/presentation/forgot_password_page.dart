import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/dependency/app_services.dart';
import '../../../core/network/api_client.dart';

class ForgotPasswordPage
    extends StatefulWidget {
  const ForgotPasswordPage({
    super.key,
  });

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {
  final _emailFormKey =
      GlobalKey<FormState>();

  final _resetFormKey =
      GlobalKey<FormState>();

  final _emailController =
      TextEditingController();

  final _codeController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _confirmPasswordController =
      TextEditingController();

  bool _codeRequested = false;
  bool _resetComplete = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (_emailFormKey.currentState
            ?.validate() !=
        true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AppServices.authService
          .forgotPassword(
        _emailController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _codeRequested = true;
      });
    } on ApiException catch (exception) {
      AppServices.errorHandler
          .showApiException(
        exception,
        title:
            'Could not request password reset',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_resetFormKey.currentState
            ?.validate() !=
        true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AppServices.authService
          .resetPassword(
        email:
            _emailController.text.trim(),
        code:
            _codeController.text.trim(),
        newPassword:
            _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _resetComplete = true;
      });
    } on ApiException catch (exception) {
      AppServices.errorHandler
          .showApiException(
        exception,
        title:
            'Could not reset password',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Reset password'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 420,
            ),
            child: Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  24,
                ),
                child:
                    _resetComplete
                        ? _buildComplete()
                        : _codeRequested
                            ? _buildResetForm()
                            : _buildEmailForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _emailFormKey,
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Forgot password?',
            style: TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter the email address associated with your account. '
            'If the account exists, we will send you a reset code.',
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller:
                _emailController,
            enabled: !_isLoading,
            keyboardType:
                TextInputType
                    .emailAddress,
            decoration:
                const InputDecoration(
              labelText: 'Email',
            ),
            validator: (value) {
              final email =
                  value?.trim() ?? '';

              if (email.isEmpty) {
                return 'Email is required.';
              }

              if (!email.contains('@')) {
                return 'Enter a valid email address.';
              }

              return null;
            },
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed:
                _isLoading
                    ? null
                    : _requestCode,
            child:
                _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Send reset code',
                      ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (_) => false,
                    );
                  },
            child: const Text('Back to login'),
          ),
        ],
      ),
    );
  }

  Widget _buildResetForm() {
    return Form(
      key: _resetFormKey,
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter reset code',
            style: TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A reset code was sent to ${_emailController.text.trim()}.',
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller:
                _codeController,
            enabled: !_isLoading,
            keyboardType:
                TextInputType.number,
            maxLength: 6,
            decoration:
                const InputDecoration(
              labelText: 'Reset code',
            ),
            validator: (value) {
              final code =
                  value?.trim() ?? '';

              if (code.length != 6) {
                return 'Enter the 6-digit reset code.';
              }

              if (int.tryParse(code) ==
                  null) {
                return 'Reset code must contain only numbers.';
              }

              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller:
                _passwordController,
            enabled: !_isLoading,
            obscureText: true,
            decoration:
                const InputDecoration(
              labelText:
                  'New password',
            ),
            validator: (value) {
              if (value == null ||
                  value.isEmpty) {
                return 'New password is required.';
              }

              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller:
                _confirmPasswordController,
            enabled: !_isLoading,
            obscureText: true,
            decoration:
                const InputDecoration(
              labelText:
                  'Confirm password',
            ),
            validator: (value) {
              if (value !=
                  _passwordController
                      .text) {
                return 'Passwords do not match.';
              }

              return null;
            },
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed:
                _isLoading
                    ? null
                    : _resetPassword,
            child:
                _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Reset password',
                      ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed:
                _isLoading
                    ? null
                    : () {
                        setState(() {
                          _codeRequested =
                              false;
                          _codeController
                              .clear();
                        });
                      },
            child:
                const Text(
              'Use a different email',
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (_) => false,
                    );
                  },
            child: const Text('Back to login'),
          ),
        ],
      ),
    );
  }

  Widget _buildComplete() {
    return Column(
      mainAxisSize:
          MainAxisSize.min,
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 56,
        ),
        const SizedBox(height: 16),
        const Text(
          'Password updated',
          textAlign:
              TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your password has been reset successfully. '
          'You can now sign in with your new password.',
          textAlign:
              TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(
              AppRoutes.login,
              (_) => false,
            );
          },
          child:
              const Text('Back to login'),
        ),
      ],
    );
  }
}