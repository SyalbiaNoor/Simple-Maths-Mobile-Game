import 'package:flutter/material.dart';

class CellWidget extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const CellWidget({super.key, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          border: Border.all(color: Colors.black, width: 1.5),
        ),
      ),
    );
  }
}
