import 'package:flutter/material.dart';

class LockedVideoOverlay extends StatelessWidget {
  const LockedVideoOverlay({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: .48),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: Colors.white,
              size: 42,
            ),
            SizedBox(height: 10),
            Text(
              'Subscribe to view',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}