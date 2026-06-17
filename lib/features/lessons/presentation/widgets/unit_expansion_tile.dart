// lib/features/lessons/widgets/unit_expansion_tile.dart
import 'package:fahem/core/constants/colors.dart';
import 'package:flutter/material.dart';

class UnitExpansionTile extends StatelessWidget {
  final String title;
  final List<Widget> lessons;
  final bool initiallyExpanded;

  const UnitExpansionTile({
    super.key,
    required this.title,
    required this.lessons,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom:15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.commonShadow,
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          childrenPadding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
          trailing: const Icon(Icons.expand_more_rounded, color: AppColors.primary, size: 28),
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          children: lessons,
        ),
      ),
    );
  }
}