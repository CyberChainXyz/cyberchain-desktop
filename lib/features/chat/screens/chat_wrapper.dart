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

    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) {
        // If we have a user and are connected, show chat screen
        if (chatState.currentUser != null && chatState.isConnected) {
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const ChatScreen(),
            transitionDuration: Duration.zero,
          );
        }

        // Otherwise show setup screen
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const UserSetupScreen(),
          transitionDuration: Duration.zero,
        );
      },
    );
  }
}
