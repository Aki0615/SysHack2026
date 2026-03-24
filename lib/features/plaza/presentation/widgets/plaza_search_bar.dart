import 'package:flutter/material.dart';

/// 広場画面用の検索バーWidget
class PlazaSearchBar extends StatelessWidget {
  const PlazaSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF3AAA3A), width: 1),
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: '人名・イベント名で検索',
            hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Color(0xFF3AAA3A)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}
