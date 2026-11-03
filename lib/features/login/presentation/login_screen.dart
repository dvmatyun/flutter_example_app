import 'package:flutter/material.dart';
import 'package:flutter_dvmatyun/app/data/app_scope.dart';
import 'package:flutter_dvmatyun/app/presentation/routes.dart';
import 'package:flutter_dvmatyun/features/login/presentation/login_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginTe = TextEditingController();
  final _passwordTe = TextEditingController();
  late final userController = AppScope.ofGet(context).userController;
  late LoginState _previousState;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _previousState = userController.state;
    userController.addListener(_onStateChanged);
  }

  /// Reacts to state transitions only, so every navigation or dialog
  /// happens once per change, not on every notification.
  void _onStateChanged() {
    final previous = _previousState;
    final state = _previousState = userController.state;
    if (previous.user == null && state.user != null) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      return;
    }
    final error = state.error;
    if (error != null && error != previous.error) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog.adaptive(
          title: const Text('Login failed'),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    userController.login(
      login: _loginTe.text.trim(),
      password: _passwordTe.text,
    );
  }

  static String? _validateNotEmpty(String? value, String message) =>
      value == null || value.trim().isEmpty ? message : null;

  @override
  void dispose() {
    userController.removeListener(_onStateChanged);
    _loginTe.dispose();
    _passwordTe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ListenableBuilder(
            listenable: userController,
            builder: (context, _) {
              final state = userController.state;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: state.isLoading
                          ? const Center(
                              child: CircularProgressIndicator.adaptive(),
                            )
                          : AutofillGroup(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      'Log in to continue',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                    const SizedBox(height: 32),
                                    TextFormField(
                                      controller: _loginTe,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.username,
                                      ],
                                      validator: (value) => _validateNotEmpty(
                                        value,
                                        'Enter your login',
                                      ),
                                      decoration: const InputDecoration(
                                        labelText: 'Login',
                                        prefixIcon: Icon(Icons.people),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _passwordTe,
                                      obscureText: _obscurePassword,
                                      textInputAction: TextInputAction.done,
                                      autocorrect: false,
                                      enableSuggestions: false,
                                      autofillHints: const [
                                        AutofillHints.password,
                                      ],
                                      validator: (value) => _validateNotEmpty(
                                        value,
                                        'Enter your password',
                                      ),
                                      onFieldSubmitted: (_) => _submit(),
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: const Icon(Icons.password),
                                        suffixIcon: IconButton(
                                          tooltip: _obscurePassword
                                              ? 'Show password'
                                              : 'Hide password',
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                          onPressed: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    FilledButton(
                                      onPressed: _submit,
                                      child: const SizedBox(
                                        height: 48,
                                        child: Center(child: Text('Log in')),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
