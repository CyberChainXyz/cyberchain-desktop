import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../utils/avatar_generator.dart';

class UserSetupScreen extends ConsumerStatefulWidget {
  const UserSetupScreen({super.key});

  @override
  ConsumerState<UserSetupScreen> createState() => _UserSetupScreenState();
}

class _UserSetupScreenState extends ConsumerState<UserSetupScreen> {
  final _nameController = TextEditingController();
  String? _currentSeed;
  DicebearStyle _currentStyle = DicebearStyle.avataaars;
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showAvatarPicker() {
    // Calculate exact height:
    // - Drag handle: 28px (12px padding * 2 + 4px height)
    // - Tab bar: 48px
    // - Grid padding: 32px (16px * 2)
    // - Grid: 4 rows * (48px avatar + 8px spacing) + 2px border * 2
    // Total: 28 + 48 + 32 + (4 * 56) + 4 = 336px
    const totalHeight = 366.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DefaultTabController(
        length: DicebearStyle.values.length,
        child: SafeArea(
          child: Center(
            child: Container(
              width: 360,
              height: totalHeight,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Tab Bar
                  TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.center,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                    tabs: DicebearStyle.values
                        .map((style) => Tab(text: style.displayName))
                        .toList(),
                    onTap: (index) {
                      setState(() {
                        _currentStyle = DicebearStyle.values[index];
                      });
                    },
                  ),
                  // Grid View
                  Expanded(
                    child: TabBarView(
                      children: DicebearStyle.values
                          .map((style) => Padding(
                                padding: const EdgeInsets.all(16),
                                child: AvatarGenerator.buildAvatarGrid(
                                  _currentSeed ?? '',
                                  style,
                                  (seed) {
                                    setState(() {
                                      _currentSeed = seed;
                                      _currentStyle = style;
                                    });
                                    Navigator.pop(context);
                                  },
                                  avatarSize: 48,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    if (_currentSeed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an avatar')),
      );
      return;
    }

    if (_isLoading || _isSubmitting) return;

    _isSubmitting = true;
    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(chatProvider.notifier);
      await notifier.createUser(
        _nameController.text.trim(),
        AvatarGenerator.generateAvatarId(_currentSeed!, _currentStyle),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        _isSubmitting = false;
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anonymous Chat Room'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar Selection
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: _currentSeed == null
                            ? Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.person_outline,
                                    size: 48,
                                    color: colorScheme.onSurfaceVariant
                                        .withOpacity(0.5),
                                  ),
                                ),
                              )
                            : AvatarGenerator.buildAvatar(
                                _currentSeed!,
                                style: _currentStyle,
                                size: 120,
                              ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            mouseCursor: SystemMouseCursors.click,
                            onTap: _isLoading ? null : _showAvatarPicker,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                _currentSeed == null ? Icons.add : Icons.edit,
                                size: 20,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Name Input
                  TextField(
                    controller: _nameController,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'Your Name',
                      hintText: 'Enter a display name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This is how others will see you in the chat',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed:
                      (_isLoading || _isSubmitting) ? null : _handleSubmit,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Start Chatting'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
