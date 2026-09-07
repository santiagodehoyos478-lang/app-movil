import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          side: const BorderSide(color: Colors.blueAccent, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
      );
    }
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1B3B6F),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}