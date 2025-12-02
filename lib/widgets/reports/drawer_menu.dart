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

class _ReportTabViewState extends State<ReportTabView>
    with SingleTickerProviderStateMixin {
  int _selected = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> content = _selected == 0
        ? widget.dailyContent
        : _selected == 1
            ? widget.weeklyContent
            : widget.monthlyContent;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.brown.shade50,
            borderRadius: BorderRadius.circular(30),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.brown.shade800,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.brown.shade700,
            ),
            onTap: (i) => setState(() => _selected = i),
            tabs: const [
              Tab(text: "Daily"),
              Tab(text: "Weekly"),
              Tab(text: "Monthly"),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: content),
          ),
        ),
      ],
    );
  }
}