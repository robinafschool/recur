import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  final _entryController = TextEditingController();
  final _textFieldKey = GlobalKey();
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  bool _showScanEffect = true;
  final List<_Particle> _particles = [];
  String _previousText = '';

  @override
  void initState() {
    super.initState();
    _initScanAnimation();
    _entryController.addListener(_onTextChanged);
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
    final currentText = _entryController.text;
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

      if (_textFieldKey.currentContext != null) {
        RenderEditable? renderEditable;
        RenderBox? containerRenderBox =
            _textFieldKey.currentContext!.findRenderObject() as RenderBox?;

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
          final selection = _entryController.selection;
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
    _entryController.removeListener(_onTextChanged);
    _entryController.dispose();
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
            Expanded(child: _buildEntryBox()),
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

  Widget _buildEntryBox() {
    return Container(
      key: _textFieldKey,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: TextField(
        controller: _entryController,
        decoration: const InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.zero,
          hintText:
              'Write your freeform journal entry here... Habits mentioned in your entries (e.g., \'I want to exercise every morning\' or \'wash hair every 4 days\') will be automatically created and scheduled.',
          hintStyle: TextStyle(
            color: AppTheme.textTertiary,
            fontSize: AppTheme.fontSizeMedium,
            height: 1.5,
          ),
        ),
        style: AppTheme.body.copyWith(color: AppTheme.textPrimary, height: 1.5),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
      ),
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
