import 'package:flutter/material.dart';

class ReportTabView extends StatefulWidget {
  final List<Widget> dailyContent;
  final List<Widget> weeklyContent;
  final List<Widget> monthlyContent;

  const ReportTabView({
    Key? key,
    required this.dailyContent,
    required this.weeklyContent,
    required this.monthlyContent,
  }) : super(key: key);

  @override
  State<ReportTabView> createState() => _ReportTabViewState();
}

class _ReportTabViewState extends State<ReportTabView> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> content = _selected == 0
        ? widget.dailyContent
        : _selected == 1
            ? widget.weeklyContent
            : widget.monthlyContent;

    return Column(
      children: [
        const SizedBox(height: 12),

        // === CUSTOM TAB BUTTONS ===
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFF6E200D), width: 1),
          ),
          child: Row(
            children: [
              _buildTabButton("Daily", 0),
              _buildTabButton("Weekly", 1),
              _buildTabButton("Monthly", 2),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // === CONTENT ===
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, int index) {
    bool active = _selected == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selected = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF6E200D) : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF6E200D),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
