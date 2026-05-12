import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom slide transition that slides from right to left
class SlideFromRightTransition extends CustomTransitionPage<void> {
  SlideFromRightTransition({
    required super.key,
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
  }) : super(
         transitionDuration: const Duration(milliseconds: 300),
         reverseTransitionDuration: const Duration(milliseconds: 250),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return SlideTransition(
             position:
                 Tween<Offset>(
                   begin: const Offset(1.0, 0.0), // Start from right
                   end: Offset.zero, // End at center
                 ).animate(
                   CurvedAnimation(
                     parent: animation,
                     curve: Curves.easeOutCubic,
                   ),
                 ),
             child: SlideTransition(
               position:
                   Tween<Offset>(
                     begin: Offset.zero,
                     end: const Offset(
                       -0.3,
                       0.0,
                     ), // Slide previous page to left
                   ).animate(
                     CurvedAnimation(
                       parent: secondaryAnimation,
                       curve: Curves.easeOutCubic,
                     ),
                   ),
               child: child,
             ),
           );
         },
       );
}

/// Fade transition for modal-like screens
class FadeTransitionPage extends CustomTransitionPage<void> {
  FadeTransitionPage({
    required super.key,
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
  }) : super(
         transitionDuration: const Duration(milliseconds: 250),
         reverseTransitionDuration: const Duration(milliseconds: 200),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return FadeTransition(
             opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
             child: child,
           );
         },
       );
}

/// Scale transition for dialog-like screens
class ScaleTransitionPage extends CustomTransitionPage<void> {
  ScaleTransitionPage({
    required super.key,
    required super.child,
    super.name,
    super.arguments,
    super.restorationId,
  }) : super(
         transitionDuration: const Duration(milliseconds: 300),
         reverseTransitionDuration: const Duration(milliseconds: 250),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return ScaleTransition(
             scale: Tween<double>(begin: 0.8, end: 1.0).animate(
               CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
             ),
             child: FadeTransition(
               opacity: CurvedAnimation(
                 parent: animation,
                 curve: Curves.easeOut,
               ),
               child: child,
             ),
           );
         },
       );
}

/// Hero-style transition for avatar navigation
class HeroAvatarTransition extends StatelessWidget {
  final String heroTag;
  final Widget child;

  const HeroAvatarTransition({
    super.key,
    required this.heroTag,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Material(color: Colors.transparent, child: child),
    );
  }
}
