import 'package:flutter/material.dart';
import 'package:vidivideo_app/src/core/dependency/app_services.dart';
import 'package:vidivideo_app/src/core/network/api_client.dart';
import 'package:flutter/foundation.dart';

import '../../../app/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AppServices.authService;
  final _sessionStore = AppServices.sessionStore;

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      final role =
          response.role.trim().toLowerCase();

      final isStaff = role == 'admin' || role == 'moderator' || role == 'super admin';

      final isWindows =
          !kIsWeb &&
          defaultTargetPlatform ==
              TargetPlatform.windows;

      final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android; 

      if (isWindows && !isStaff) {
        _sessionStore.clearSession();

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Administrator account is required '
                'for the desktop application.',
              ),
            ),
          );

        return;
      }

      if (isAndroid && isStaff) {
        _sessionStore.clearSession();

        if (!mounted) {
          return;
        }
          
          ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text(
              'User account is required '
              'for the mobile application.'
              ),
            ),
          );
        return;
      }



      _sessionStore.saveSession(
        accessToken: response.token,
        role: response.role,
      );

      if (!mounted) {
        return;
      }

      if (isWindows && isStaff) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(
          AppRoutes.adminDashboard,
          (_) => false,
        );

        return;
      }

      Navigator.of(context)
          .pushNamedAndRemoveUntil(
        AppRoutes.mobileShell,
        (_) => false,
      );
    } on ApiException catch (exception) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Login failed '
              '(${exception.statusCode}): '
              '${exception.message}',
            ),
          ),
        );
    } catch (exception) {
      debugPrint(
        'LOGIN ERROR: $exception',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to connect to the server.',
            ),
          ),
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
    final isWindows = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'VidiVideo',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign in to continue',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _usernameController,
                      enabled: !_isLoading,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username is required.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_isLoading,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Sign in'),
                    ),
                    if (!isWindows) ...[
                      const SizedBox(height: 8),
                      FilledButton(
            
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.of(context).pushReplacementNamed(
                                  AppRoutes.register,
                                );
                              },
                        child: const Text('Create account'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.of(context).pushReplacementNamed(
                                  AppRoutes.mobileShell,
                                );
                              },
                        child: const Text('Open mobile preview'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
