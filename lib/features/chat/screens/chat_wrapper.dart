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
        if (chatState.currentUser != null && !chatState.isConnected)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.red.shade700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Reconnecting...',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
