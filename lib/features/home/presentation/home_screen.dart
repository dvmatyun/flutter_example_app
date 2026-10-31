import 'package:flutter/material.dart';
import 'package:flutter_dvmatyun/app/data/app_scope.dart';
import 'package:flutter_dvmatyun/app/presentation/routes.dart';

/// {@template home_screen}
/// HomeScreen widget.
/// {@endtemplate}
class HomeScreen extends StatefulWidget {
  /// {@macro home_screen}
  const HomeScreen({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State for widget HomeScreen.
class _HomeScreenState extends State<HomeScreen> {
  late final userController = AppScope.ofGet(context).userController;

  @override
  void initState() {
    super.initState();
    userController.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    final state = userController.state;
    if (state.user == null) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
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
              child: const Text('Got it'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    userController.removeListener(_onStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: userController,
        builder: (context, _) {
          if (userController.state.isLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text('Home'),
                actions: [
                  IconButton(
                    tooltip: 'Logout',
                    onPressed: userController.logout,
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
              const SliverToBoxAdapter(child: _HomeCards()),
              const SliverToBoxAdapter(child: _GameInvitation()),
            ],
          );
        },
      ),
    );
  }
}

class _HomeCards extends StatelessWidget {
  const _HomeCards();

  static const _cards = [
    (icon: Icons.bolt, title: 'Daily challenge'),
    (icon: Icons.leaderboard, title: 'Leaderboard'),
    (icon: Icons.emoji_events, title: 'Achievements'),
    (icon: Icons.group, title: 'Friends'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        itemCount: _cards.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final card = _cards[index];
          return SizedBox(
            width: 140,
            child: Card(
              margin: EdgeInsets.zero,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(card.icon, size: 32),
                  const SizedBox(height: 8),
                  Text(card.title, textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GameInvitation extends StatelessWidget {
  const _GameInvitation();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height),
      child: ColoredBox(
        color: theme.colorScheme.primaryContainer,
        child: Center(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, size: 72),
                  const SizedBox(height: 24),
                  Text(
                    'Ready to play Star Catcher?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Stars fall from the sky. Tap them before they reach the '
                    'ground. Every star scores a point, and three misses end '
                    'the round.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon')),
                      );
                    },
                    child: const Text('Play'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
