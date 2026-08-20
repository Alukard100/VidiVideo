import 'package:flutter/material.dart';

class SubscribedButton extends StatelessWidget {
  const SubscribedButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF2D95),
            Color(0xFFEE4D8B),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF2D95)
                .withValues(alpha: .32),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: const Color(0xFF25F4EE)
                .withValues(alpha: .20),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 18,
          ),
          SizedBox(width: 6),
          Text(
            'Subscribed',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}