import 'package:flutter/material.dart';

import '../../widgets/dashboard/bar_chart.dart';
import '../../widgets/dashboard/line_chart.dart';
import '../../widgets/sidebar_menu.dart';
import '../../widgets/dashboard/info_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedPeriod = "Monthly";

  final Map<String, List<double>> salesData = {
    "Monthly": [80, 30, 100, 85, 70, 60],
    "Weekly": [20, 50, 40, 70, 60, 90],
  };

  void _openCustomSidebar(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: size.width < 600 ? size.width * 0.8 : 350,
              height: size.height * 0.9,
              margin: const EdgeInsets.only(top: 40, bottom: 60),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                child: Material(
                  color: Colors.white,
                  child: SidebarMenu(selected: "dashboard"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        final bool isSmall = screenWidth < 360;
        final bool isTablet = screenWidth >= 650;

        final double paddingHorizontal = isSmall ? 16 : 28;
        final double headerFont = isSmall ? 18 : 24;
        final double cardSpacing = isSmall ? 20 : 26;

        final double chartHeight = isSmall ? 170 : (isTablet ? 280 : 220);

        final data = salesData[selectedPeriod]!;

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 25, left: 25),
                child: AppBar(
                  titleSpacing: 0,
                  elevation: 0,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  automaticallyImplyLeading: false,
                  title: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: Color(0xFF6E200D),
                          size: 28,
                        ),
                        onPressed: () => _openCustomSidebar(context),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Dashboard",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: headerFont,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: paddingHorizontal,
              right: paddingHorizontal,
              bottom: 20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: cardSpacing),
                    DashboardCards(activeCard: ""),
                    SizedBox(height: isSmall ? 20 : 26),
                    Text(
                      "Statistic",
                      style: TextStyle(
                        fontSize: isSmall ? 18 : 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8E3D8),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Sales Overview",
                                style: TextStyle(
                                  fontSize: isSmall ? 15 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                height: 30,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2B6A3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedPeriod,
                                    isDense: true,
                                    dropdownColor: const Color(0xFFF8E3D8),
                                    items: const [
                                      DropdownMenuItem(
                                        value: "Monthly",
                                        child: Text("Monthly"),
                                      ),
                                      DropdownMenuItem(
                                        value: "Weekly",
                                        child: Text("Weekly"),
                                      ),
                                    ],
                                    onChanged: (value) =>
                                        setState(() => selectedPeriod = value!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: chartHeight,
                            child: BarSalesChart(data: data),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8E3D8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Daily Sales",
                            style: TextStyle(
                              fontSize: isSmall ? 15 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: chartHeight,
                            child: const LineSalesChart(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
