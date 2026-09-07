import 'package:flutter/material.dart';

class StatusCounter extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const StatusCounter({
    super.key,
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            count.toString().padLeft(2, '0'),
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}