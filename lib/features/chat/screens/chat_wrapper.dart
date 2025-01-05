import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';
import 'user_setup_screen.dart';

class ChatWrapper extends ConsumerStatefulWidget {
  const ChatWrapper({super.key});

  @override
  ConsumerState<ChatWrapper> createState() => _ChatWrapperState();
}

class _ChatWrapperState extends ConsumerState<ChatWrapper> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    // Show loading indicator during initialization
    if (chatState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Listen to currentUser changes and update navigation
    ref.listen<ChatState>(chatProvider, (previous, next) {
      if (previous?.currentUser == null && next.currentUser != null) {
        // User was just created, force navigation update
        _navigatorKey.currentState?.pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const ChatScreen(),
            transitionDuration: Duration.zero,
          ),
        );
      }
    });

    return Stack(
      children: [
        Navigator(
          key: _navigatorKey,
          onGenerateRoute: (settings) {
            // Only check for user existence, not connection state
            if (chatState.currentUser != null) {
              return PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ChatScreen(),
                transitionDuration: Duration.zero,
              );
            }

            // Show setup screen only when no user exists
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const UserSetupScreen(),
              transitionDuration: Duration.zero,
            );
          },
        ),
      ],
    );
  }
}
