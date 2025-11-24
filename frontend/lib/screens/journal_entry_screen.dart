import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../config/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/gradient_header.dart';
import '../utils/route_generator.dart';
import 'analytics_screen.dart';
import 'journal_list_screen.dart';
import 'ai_schedule_screen.dart';
import 'settings_screen.dart';

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
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 1200), // Faster animation
      vsync: this,
    );
    _scanAnimation = CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeOut,
    );
    // Hide effect when animation completes
    _scanController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showScanEffect = false;
        });
      }
    });
    // Start the scan animation when screen opens
    _scanController.forward();

    // Listen for text changes to create particles
    _entryController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final currentText = _entryController.text;
    if (currentText.length > _previousText.length) {
      // New character typed
      final newChar = currentText.substring(_previousText.length);
      if (newChar.isNotEmpty) {
        _createParticle(newChar);
      }
    }
    _previousText = currentText;
  }

  void _createParticle(String character) {
    // Calculate cursor position when particle is created
    // Use post-frame callback to ensure layout is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Offset? cursorPosition;

      if (_textFieldKey.currentContext != null) {
        // Find the RenderEditable object from the TextField
        RenderEditable? renderEditable;
        RenderBox? containerRenderBox =
            _textFieldKey.currentContext!.findRenderObject() as RenderBox?;

        // Traverse the render tree to find RenderEditable
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
          // Get the current cursor position
          final selection = _entryController.selection;
          final textPosition = TextPosition(offset: selection.baseOffset);

          // Use RenderEditable's getLocalRectForCaret for accurate cursor position
          // This accounts for text wrapping, line breaks, and all layout details
          final caretRect = renderEditable!.getLocalRectForCaret(textPosition);

          // Measure the character width to position it on the left side of cursor
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

          // Position on the left side of the cursor (offset by character width)
          final localCaretOffset = Offset(
            caretRect.left - charWidth,
            caretRect.top,
          );

          // Convert to global coordinates using the RenderEditable's position
          final globalCaretOffset = renderEditable!.localToGlobal(
            localCaretOffset,
          );

          cursorPosition = globalCaretOffset;

          // Create particle with calculated position
          _createParticleWithPosition(character, cursorPosition);
        } else {
          // Fallback if RenderEditable not found
          _createParticleWithPosition(character, null);
        }
      } else {
        // Fallback if context not available
        _createParticleWithPosition(character, null);
      }
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

    setState(() {
      _particles.add(particle);
    });

    controller.forward().then((_) {
      setState(() {
        _particles.remove(particle);
      });
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

  static const int _currentIndex = 2; // Journal Entry is middle item

  void _navigateToScreen(int index) {
    if (index == _currentIndex)
      return; // Don't navigate if already on this screen

    final routes = [
      '/analytics',
      '/journal-list',
      '/journal-entry',
      '/ai-schedule',
      '/settings',
    ];
    final direction = getSlideDirection(_currentIndex, index);

    Navigator.pushReplacement(
      context,
      SlideRoute(page: _getRouteWidget(routes[index]), direction: direction),
    );
  }

  Widget _getRouteWidget(String route) {
    switch (route) {
      case '/analytics':
        return const AnalyticsScreen();
      case '/journal-list':
        return const JournalListScreen();
      case '/journal-entry':
        return const JournalEntryScreen();
      case '/ai-schedule':
        return const AiScheduleScreen();
      case '/settings':
        return const SettingsScreen();
      default:
        return const JournalEntryScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.7),
            AppTheme.primaryLight.withOpacity(0.5),
          ],
        ),
      ),
      child: SafeArea(
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
      ),
    );

    final body = Stack(
      children: [
        content,
        // Particle animations
        ..._particles.map((particle) => _buildParticle(particle)),
        // Circular gradient spreading from center button
        if (_showScanEffect)
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              final screenSize = MediaQuery.of(context).size;
              final maxRadius =
                  screenSize.height * 1.2; // Large enough to cover screen
              final currentRadius = maxRadius * _scanAnimation.value;
              // Invert opacity: start visible, fade to invisible
              final opacityMultiplier = 1.0 - _scanAnimation.value;
              // Button is at bottom center, account for navbar height
              final buttonY = 0.0; // Bottom of screen
              final buttonX = screenSize.width / 2; // Center horizontally

              return Positioned(
                bottom:
                    buttonY -
                    currentRadius, // Center the circle at button position
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
                          Colors.white.withOpacity(1.0 * opacityMultiplier),
                          Colors.white.withOpacity(0.7 * opacityMultiplier),
                          AppTheme.primaryColor.withOpacity(
                            0.5 * opacityMultiplier,
                          ),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );

    if (!widget.showNavBar) {
      return SizedBox.expand(child: body);
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _navigateToScreen,
      ),
    );
  }

  Widget _buildParticle(_Particle particle) {
    return AnimatedBuilder(
      animation: particle.animation,
      builder: (context, child) {
        final screenSize = MediaQuery.of(context).size;

        // Use stored cursor position or fallback
        double cursorX = screenSize.width * 0.1;
        double cursorY = screenSize.height * 0.45;

        if (particle.startPosition != null) {
          cursorX = particle.startPosition!.dx;
          cursorY = particle.startPosition!.dy;
        }

        // Button position (bottom center, where journal entry button is)
        final buttonX = screenSize.width / 2;
        final buttonY = screenSize.height - 40; // Bottom nav bar position

        // Interpolate position with easing
        final t = particle.animation.value;
        final currentX = cursorX + (buttonX - cursorX) * t;
        final currentY = cursorY + (buttonY - cursorY) * t;

        // Fade out and scale down as it approaches button
        final opacity = (1.0 - t) * 0.9;
        final scale = 1.0 - (t * 0.5); // Shrink slightly

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
                        color: AppTheme.primaryColor.withOpacity(0.5),
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
