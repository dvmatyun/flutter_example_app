import 'package:flutter/material.dart';
import 'package:flutter_dvmatyun/app/data/app_scope.dart';
import 'package:flutter_dvmatyun/app/presentation/routes.dart';
import 'package:flutter_dvmatyun/features/login/data/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginTe = TextEditingController();
  final _passwordTe = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _loginTe.dispose();
    _passwordTe.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final appScope = AppScope.of(context);
    final navigator = Navigator.of(context);
    setState(() {
      _isLoading = true;
    });
    User? user;
    try {
      user = await appScope.userService.login(
        login: _loginTe.text,
        password: _loginTe.text,
      );
    } on Object catch (e, st) {
      debugPrint(' > Error: $e , st=[$st]');
    }
    if (!mounted) return;

    if (user != null) {
      navigator.pushReplacementNamed(AppRoutes.home);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: _isLoading
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
                                autofillHints: const [AutofillHints.username],
                                decoration: const InputDecoration(
                                  labelText: 'Login',
                                  prefixIcon: Icon(Icons.people),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _passwordTe,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                autocorrect: false,
                                enableSuggestions: false,
                                autofillHints: const [AutofillHints.password],
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
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              FilledButton(
                                onPressed: _onLogin,
                                child: SizedBox(
                                  height: 48,
                                  child: Center(child: const Text('Log in')),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
