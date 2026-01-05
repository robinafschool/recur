import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_theme.dart';
import '../widgets/widgets.dart';
import '../navigation/navigation.dart';

class JournalEntryScreen extends StatefulWidget {
  final bool showNavBar;

  const JournalEntryScreen({super.key, this.showNavBar = true});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _dreamControllers = [TextEditingController()];
  final List<GlobalKey> _textFieldKeys = [GlobalKey()];
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  bool _showScanEffect = true;
  final List<_Particle> _particles = [];
  String _previousText = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initScanAnimation();
    _dreamControllers[0].addListener(_onTextChanged);
  }

  void _initScanAnimation() {
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scanAnimation = CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeOut,
    );
    _scanController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showScanEffect = false);
      }
    });
    _scanController.forward();
  }

  void _onTextChanged() {
    final currentText = _dreamControllers[0].text;
    if (currentText.length > _previousText.length) {
      final newChar = currentText.substring(_previousText.length);
      if (newChar.isNotEmpty) {
        _createParticle(newChar);
      }
    }
    _previousText = currentText;
  }

  void _createParticle(String character) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Offset? cursorPosition;

      if (_textFieldKeys[0].currentContext != null) {
        RenderEditable? renderEditable;
        RenderBox? containerRenderBox =
            _textFieldKeys[0].currentContext!.findRenderObject() as RenderBox?;

        if (containerRenderBox != null) {
          void findRenderEditable(RenderObject? obj) {
            if (obj == null) return;
            if (obj is RenderEditable) {
              renderEditable = obj;
              return;
            }
            if (obj is RenderBox && obj is! RenderEditable) {
              obj.visitChildren(findRenderEditable);
            }
          }

          findRenderEditable(containerRenderBox);
        }

        if (renderEditable != null) {
          final selection = _dreamControllers[0].selection;
          final textPosition = TextPosition(offset: selection.baseOffset);
          final caretRect = renderEditable!.getLocalRectForCaret(textPosition);

          final textStyle = AppTheme.body.copyWith(
            color: AppTheme.textPrimary,
            height: 1.5,
          );
          final charPainter = TextPainter(
            text: TextSpan(text: character, style: textStyle),
            textDirection: TextDirection.ltr,
          );
          charPainter.layout();
          final charWidth = charPainter.width;

          final localCaretOffset = Offset(
            caretRect.left - charWidth,
            caretRect.top,
          );

          cursorPosition = renderEditable!.localToGlobal(localCaretOffset);
        }
      }

      _createParticleWithPosition(character, cursorPosition);
    });
  }

  void _addDream() {
    setState(() {
      final controller = TextEditingController();
      _dreamControllers.add(controller);
      _textFieldKeys.add(GlobalKey());
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one dream')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final now = DateTime.now();
      final date = DateTime(now.year, now.month, now.day);

      for (int i = 0; i < nonEmptyDreams.length; i++) {
        await Supabase.instance.client.from('journal_entries').insert({
          'user_id': user.id,
          'content': nonEmptyDreams[i],
          'date': date.toIso8601String().split('T')[0],
          'time': now.add(Duration(seconds: i)).toIso8601String().split('T')[1].split('.')[0],
          'metadata': {'dream_index': i, 'dream_order': i + 1},
        });
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved ${nonEmptyDreams.length} dream${nonEmptyDreams.length > 1 ? 's' : ''}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving dreams: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _createParticleWithPosition(String character, Offset? cursorPosition) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    final particle = _Particle(
      character: character,
      controller: controller,
      animation: animation,
      startPosition: cursorPosition,
    );

    setState(() => _particles.add(particle));

    controller.forward().then((_) {
      setState(() => _particles.remove(particle));
      controller.dispose();
    });
  }

  @override
  void dispose() {
    _dreamControllers[0].removeListener(_onTextChanged);
    for (var controller in _dreamControllers) {
      controller.dispose();
    }
    _scanController.dispose();
    for (var particle in _particles) {
      particle.controller.dispose();
    }
    super.dispose();
  }

  void _navigateToScreen(int index) {
    AppNavigator.navigateToIndex(context, NavIndex.journalEntry, index);
  }

  @override
  Widget build(BuildContext context) {
    final content = GradientScaffold(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const GradientHeader(
              icon: Icons.edit,
              title: 'New Journal Entry',
              description:
                  'Write your thoughts freely. Habits mentioned in your entries will be automatically created and scheduled.',
            ),
            const SizedBox(height: AppTheme.spacing60),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...List.generate(_dreamControllers.length, (index) => _buildDreamBox(index)),
                    const SizedBox(height: AppTheme.spacing20),
                    OutlinedButton.icon(
                      onPressed: _addDream,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Dream'),
                    ),
                    if (_dreamControllers.any((c) => c.text.trim().isNotEmpty)) ...[
                      const SizedBox(height: AppTheme.spacing20),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveDreams,
                        child: _isSaving
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Save Dreams'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final body = Stack(
      children: [
        content,
        ..._particles.map((particle) => _buildParticle(particle)),
        if (_showScanEffect) _buildScanEffect(),
      ],
    );

    if (!widget.showNavBar) {
      return SizedBox.expand(child: body);
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavBar(
        currentIndex: NavIndex.journalEntry,
        onTap: _navigateToScreen,
      ),
    );
  }

  Widget _buildScanEffect() {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, child) {
        final screenSize = MediaQuery.of(context).size;
        final maxRadius = screenSize.height * 1.2;
        final currentRadius = maxRadius * _scanAnimation.value;
        final opacityMultiplier = 1.0 - _scanAnimation.value;
        final buttonY = 0.0;
        final buttonX = screenSize.width / 2;

        return Positioned(
          bottom: buttonY - currentRadius,
          left: buttonX - currentRadius,
          width: currentRadius * 2,
          height: currentRadius * 2,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment.bottomCenter,
                  radius: 1.0,
                  colors: [
                    Colors.white.withValues(alpha: 1.0 * opacityMultiplier),
                    Colors.white.withValues(alpha: 0.7 * opacityMultiplier),
                    AppTheme.primaryColor.withValues(alpha: 0.5 * opacityMultiplier),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticle(_Particle particle) {
    return AnimatedBuilder(
      animation: particle.animation,
      builder: (context, child) {
        final screenSize = MediaQuery.of(context).size;

        double cursorX = screenSize.width * 0.1;
        double cursorY = screenSize.height * 0.45;

        if (particle.startPosition != null) {
          cursorX = particle.startPosition!.dx;
          cursorY = particle.startPosition!.dy;
        }

        final buttonX = screenSize.width / 2;
        final buttonY = screenSize.height - 40;

        final t = particle.animation.value;
        final currentX = cursorX + (buttonX - cursorX) * t;
        final currentY = cursorY + (buttonY - cursorY) * t;

        final opacity = (1.0 - t) * 0.9;
        final scale = 1.0 - (t * 0.5);

        return Positioned(
          left: currentX,
          top: currentY,
          child: IgnorePointer(
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Text(
                  particle.character,
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDreamBox(int index) {
    final isFirst = index == 0;
    final canRemove = _dreamControllers.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_dreamControllers.length > 1) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dream ${index + 1}', style: AppTheme.heading2),
              if (canRemove)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => _removeDream(index),
                  color: AppTheme.textTertiary,
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing10),
        ],
        Container(
          key: _textFieldKeys[index],
          constraints: const BoxConstraints(minHeight: 200),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          padding: const EdgeInsets.all(AppTheme.spacing20),
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
                  ? 'Write your freeform journal entry here... Habits mentioned in your entries (e.g., \'I want to exercise every morning\' or \'wash hair every 4 days\') will be automatically created and scheduled.'
                  : 'Describe another dream...',
              hintStyle: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: AppTheme.fontSizeMedium,
                height: 1.5,
              ),
            ),
            style: AppTheme.body.copyWith(color: AppTheme.textPrimary, height: 1.5),
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
          ),
        ),
        const SizedBox(height: AppTheme.spacing20),
      ],
    );
  }
}

class _Particle {
  final String character;
  final AnimationController controller;
  final Animation<double> animation;
  final Offset? startPosition;

  _Particle({
    required this.character,
    required this.controller,
    required this.animation,
    this.startPosition,
  });
}
