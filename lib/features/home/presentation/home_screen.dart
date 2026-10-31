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
                pinned: true,
                expandedHeight: kToolbarHeight + _HomeCards.height,
                flexibleSpace: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.paddingOf(context).top + kToolbarHeight,
                  ),
                  child: const _HomeCards(),
                ),
                title: const Text('Home'),
                actions: [
                  IconButton(
                    tooltip: 'Logout',
                    onPressed: userController.logout,
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
              const SliverToBoxAdapter(child: _GameInvitation()),
            ],
          );
        },
      ),
    );
  }
}

Future<void> _showComingSoon(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: const Text('Coming soon...'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Ok'),
        ),
      ],
    ),
  );
}

class _HomeCards extends StatefulWidget {
  const _HomeCards();

  static const height = 160.0;

  @override
  State<_HomeCards> createState() => _HomeCardsState();
}

class _HomeCardsState extends State<_HomeCards> {
  static const _cards = [
    (icon: Icons.bolt, title: 'Daily challenge'),
    (icon: Icons.leaderboard, title: 'Leaderboard'),
    (icon: Icons.emoji_events, title: 'Achievements'),
    (icon: Icons.group, title: 'Friends'),
  ];

  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.primary,
        ),
      ),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView.separated(
            controller: _scrollController,
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
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _showComingSoon(context),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(card.icon, size: 32),
                            const SizedBox(height: 8),
                            Text(card.title),
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

class _GameInvitation extends StatelessWidget {
  const _GameInvitation();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight:
            MediaQuery.sizeOf(context).height -
            MediaQuery.paddingOf(context).top -
            kToolbarHeight,
      ),
      child: ColoredBox(
        color: theme.colorScheme.primaryContainer,
        child: Center(
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, size: 72),
                  const SizedBox(height: 24),
                  Text(
                    'Ready to play Push them all?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tap on the screen to spawn rectangles. Tap on one another for them to collide start moving.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.gameRect),
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
