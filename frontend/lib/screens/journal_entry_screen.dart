import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../widgets/widgets.dart';
import '../navigation/navigation.dart';
import '../view_models/journal_entry_view_model.dart';

class JournalEntryScreen extends ConsumerStatefulWidget {
  final bool showNavBar;
  final VoidCallback? onSaved;

  const JournalEntryScreen({
    super.key,
    this.showNavBar = true,
    this.onSaved,
  });

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen> {
  final List<TextEditingController> _dreamControllers = [
    TextEditingController(),
  ];
  final List<GlobalKey> _textFieldKeys = [GlobalKey()];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    for (var controller in _dreamControllers) {
      controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _addDream() {
    setState(() {
      _dreamControllers.add(TextEditingController());
      _textFieldKeys.add(GlobalKey());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _removeDream(int index) {
    if (_dreamControllers.length <= 1) return;
    setState(() {
      _dreamControllers[index].dispose();
      _dreamControllers.removeAt(index);
      _textFieldKeys.removeAt(index);
    });
  }

  Future<void> _saveDreams() async {
    final nonEmptyDreams = _dreamControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (nonEmptyDreams.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter at least one dream')),
        );
      }
      return;
    }

    try {
      await ref.read(journalEntryViewModelProvider.notifier).saveDreams(nonEmptyDreams);
      if (mounted) {
        if (widget.showNavBar) {
          Navigator.pop(context);
        } else {
          widget.onSaved?.call();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Saved ${nonEmptyDreams.length} dream${nonEmptyDreams.length > 1 ? 's' : ''}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving dreams: $e')),
        );
      }
    }
  }

  void _navigateToScreen(int index) {
    AppNavigator.navigateToIndex(context, NavIndex.journalEntry, index);
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(journalEntryViewModelProvider).isSaving;
    final hasMultipleDreams = _dreamControllers.length > 1;
    final content = GradientScaffold(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GradientHeader(
              icon: Icons.edit,
              title: 'New Dream Entry',
              description:
                  'Record your dreams. Add multiple dreams per entry if you had several.',
            ),
            SizedBox(height: hasMultipleDreams ? AppTheme.spacing30 : AppTheme.spacing60),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...List.generate(
                      _dreamControllers.length,
                      (index) => _buildDreamBox(index, hasMultipleDreams),
                    ),
                    SizedBox(height: hasMultipleDreams ? AppTheme.spacing12 : AppTheme.spacing20),
                    OutlinedButton.icon(
                      onPressed: _addDream,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Dream'),
                    ),
                    SizedBox(height: hasMultipleDreams ? AppTheme.spacing12 : AppTheme.spacing20),
                    ElevatedButton(
                      onPressed: isSaving ? null : _saveDreams,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Save Dreams'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!widget.showNavBar) {
      return SizedBox.expand(child: content);
    }

    return Scaffold(
      body: content,
      bottomNavigationBar: BottomNavBar(
        currentIndex: NavIndex.journalEntry,
        onTap: _navigateToScreen,
      ),
    );
  }

  Widget _buildDreamBox(int index, bool hasMultipleDreams) {
    final isFirst = index == 0;
    final canRemove = _dreamControllers.length > 1;
    final verticalSpacing = hasMultipleDreams ? AppTheme.spacing12 : AppTheme.spacing20;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (canRemove)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => _removeDream(index),
                  style: IconButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    iconSize: 20,
                  ),
                  tooltip: 'Remove dream',
                ),
            ],
          ),
        ),
        Container(
          key: _textFieldKeys[index],
          constraints: const BoxConstraints(minHeight: 200),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          padding: EdgeInsets.all(hasMultipleDreams ? AppTheme.spacing16 : AppTheme.spacing20),
          child: TextField(
            controller: _dreamControllers[index],
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
              hintText: isFirst
                  ? 'Write your dream here… Describe what you remember from your sleep.'
                  : 'Describe another dream…',
              hintStyle: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: AppTheme.fontSizeMedium,
                height: 1.5,
              ),
            ),
            style: AppTheme.body.copyWith(
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
          ),
        ),
        SizedBox(height: verticalSpacing),
      ],
    );
  }
}
