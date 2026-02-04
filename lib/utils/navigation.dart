import 'package:flutter/material.dart';

Future<T?> pushFade<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

Future<T?> pushSlide<T>(BuildContext context, Widget page, {bool fromRight = true}) {
  final begin = fromRight ? const Offset(1, 0) : const Offset(-1, 0);
  return Navigator.of(context).push<T>(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(begin: begin, end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
        return SlideTransition(position: offsetAnimation, child: child);
      },
    ),
  );
}
