import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:miniott/gen/assets.gen.dart';
import '../../../../app/flavor/app_flavor.dart';
import '../../../../app/routes/router_configuration.dart';
import '../../../../core/services/quick_action_service.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/session_status.dart';
import '../providers/splash_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowOpacityAnimation;
  late final Animation<double> _logoOpacityAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<Offset> _logoSlideAnimation;
  late final Animation<double> _titleOpacityAnimation;
  late final Animation<double> _progressAnimation;
  late final ProviderSubscription _subscription;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _glowOpacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );

    _logoOpacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.12, 0.62, curve: Curves.easeIn),
    );

    _logoScaleAnimation = Tween<double>(
      begin: 1.24,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _logoSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.22), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.12, 0.65, curve: Curves.easeOutCubic),
          ),
        );

    _titleOpacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.85, curve: Curves.easeIn),
    );

    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.58, 1, curve: Curves.easeOutCubic),
    );

    _subscription = ref.listenManual(splashNotifierProvider, (_, next) {
      final status = next.sessionStatus;
      if (status == null || !mounted) {
        return;
      }

      if (status == SessionStatus.authenticated) {
        Future.microtask(() async {
          await ref.read(authNotifierProvider.notifier).loadCurrentUser();
          if (!mounted) {
            return;
          }
          // If the app was launched via a home-screen quick action, jump
          // straight to that target instead of bouncing through /dashboard.
          final shortcutPath = QuickActionService.consumePending();
          QuickActionService.activate();
          context.go(shortcutPath ?? AppRoutes.dashboard);
        });
      } else {
        QuickActionService.consumePending();
        QuickActionService.activate();
        context.go(AppRoutes.login);
      }
    });

    _startBootSequence();
  }

  Future<void> _startBootSequence() async {
    await _controller.forward();
    await Future<void>.delayed(const Duration(milliseconds: 180));
    await ref.read(splashNotifierProvider.notifier).checkAuthStatus();
  }

  @override
  void dispose() {
    _subscription.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: colorScheme.surface)),
          Positioned.fill(
            child: FadeTransition(
              opacity: _glowOpacityAnimation,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.1),
                    radius: 1,
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.44),
                      colorScheme.primaryContainer.withValues(alpha: 0.22),
                      colorScheme.surface,
                    ],
                    stops: const [0, 0.34, 1],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: SlideTransition(
              position: _logoSlideAnimation,
              child: FadeTransition(
                opacity: _logoOpacityAnimation,
                child: ScaleTransition(
                  scale: _logoScaleAnimation,
                  child: Container(
                    width: 148,
                    height: 148,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.2),
                          blurRadius: 24,
                          spreadRadius: 0,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.21),
                          blurRadius: 32,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.44),
                        width: 3,
                      ),
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.18),
                        radius: 0.9,
                        colors: [
                          Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.22),
                          colorScheme.surface.withValues(alpha: 0.04),
                        ],
                        stops: const [0.65, 1],
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        Assets.icon.icon.path,
                        fit: BoxFit.cover,
                        width: 148,
                        height: 148,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 88,
            child: FadeTransition(
              opacity: _titleOpacityAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppFlavorConfig.appName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.92),
                      letterSpacing: 5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 52),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        height: 3.4,
                        color: colorScheme.onSurface.withValues(alpha: 0.1),
                        alignment: Alignment.centerLeft,
                        child: AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return FractionallySizedBox(
                              widthFactor: _progressAnimation.value,
                              alignment: Alignment.centerLeft,
                              child: child,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.75,
                                  ),
                                  blurRadius: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
