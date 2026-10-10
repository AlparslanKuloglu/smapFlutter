import 'package:flutter/material.dart';

class MyCardSummaryCard extends StatelessWidget {
  const MyCardSummaryCard({
    super.key,
    required this.totalCardCount,
  });

  final int totalCardCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.layers, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 10),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.grey, fontSize: 15),
              children: [
                const TextSpan(text: 'Toplam '),
                TextSpan(
                  text: '$totalCardCount ',
                  style: const TextStyle(
                    color: Color(0xFFFF6D00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: ' bilgi kartı kazandın'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
