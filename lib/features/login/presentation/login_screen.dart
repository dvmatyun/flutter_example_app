import 'package:flutter/material.dart';
import 'package:flutter_dvmatyun/app/data/app_scope.dart';
import 'package:flutter_dvmatyun/app/presentation/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginTe = TextEditingController();
  final _passwordTe = TextEditingController();
  late final userController = AppScope.ofGet(context).userController;

  @override
  void initState() {
    super.initState();
    userController.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final state = userController.state;
    if (state.user != null) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
    final error = state.error;
    if (error != null) {
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
    final userController = AppScope.ofGet(context).userController;

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
                      padding: EdgeInsets.all(16),
                      child: state.isLoading
                          ? Center(child: CircularProgressIndicator.adaptive())
                          : AutofillGroup(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    'Log in to continue',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: 32),
                                  TextField(
                                    controller: _loginTe,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [
                                      AutofillHints.username,
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Login',
                                      prefixIcon: Icon(Icons.people),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _passwordTe,
                                    obscureText: state.obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: const Icon(Icons.password),
                                      suffixIcon: IconButton(
                                        tooltip: state.obscurePassword
                                            ? 'Show password'
                                            : 'Hide password',
                                        icon: Icon(
                                          state.obscurePassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: userController
                                            .togglePasswordVisibility,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 32),
                                  FilledButton(
                                    onPressed: () => userController.login(
                                      login: _loginTe.text,
                                      password: _passwordTe.text,
                                    ),
                                    child: SizedBox(
                                      height: 48,
                                      child: Center(
                                        child: const Text('Log in'),
                                      ),
                                    ),
                                  ),
                                ],
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
