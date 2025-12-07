import 'package:flutter/material.dart';
import 'package:aplikasi_lattelink/widgets/reports/common_widget.dart';
import 'package:aplikasi_lattelink/widgets/reports/report_tab_view.dart';

class ProfitLossScreen extends StatelessWidget {
  const ProfitLossScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daily = [
      const SizedBox(height: 8),
      const ProfitSummaryGrid(
        revenue: "1.600.000",
        cost: "1.100.000",
        profit: "500.000",
        percent: "31,25%",
      ),
      const SizedBox(height: 16),
      const ProfitChartBox(),
      const SizedBox(height: 16),

      ProfitDetailList(
        data: [
          {
            "date": "Sunday 18 Jan 2025",
            "revenue": "65.000",
            "cost": "40.000",
            "profit": "35.000",
          },
          {
            "date": "Monday 19 Jan 2025",
            "revenue": "85.000",
            "cost": "40.000",
            "profit": "45.000",
          },
          {
            "date": "Tuesday 20 Jan 2025",
            "revenue": "65.000",
            "cost": "20.000",
            "profit": "45.000",
          },
          {
            "date": "Wednesday 21 Jan 2025",
            "revenue": "61.000",
            "cost": "30.000",
            "profit": "24.000",
          },
        ],
      ),
      const SizedBox(height: 80),
    ];

    final weekly = [
      const SizedBox(height: 8),
      const ProfitSummaryGrid(
        revenue: "3.886.000",
        cost: "2.350.000",
        profit: "1.536.000",
        percent: "39,7%",
      ),
      const SizedBox(height: 16),
      const ProfitChartBox(),
      const SizedBox(height: 16),

      ProfitDetailList(
        data: [
          {
            "date": "Week 3 Jan 2025",
            "revenue": "3.886.000",
            "cost": "2.350.000",
            "profit": "1.536.000",
          },
        ],
      ),
      const SizedBox(height: 80),
    ];

    final monthly = [
      const SizedBox(height: 8),
      const ProfitSummaryGrid(
        revenue: "8.234.000",
        cost: "4.600.000",
        profit: "3.634.000",
        percent: "44,1%",
      ),
      const SizedBox(height: 16),
      const ProfitChartBox(),
      const SizedBox(height: 16),

      ProfitDetailList(
        data: [
          {
            "date": "January 2025",
            "revenue": "8.234.000",
            "cost": "4.600.000",
            "profit": "3.634.000",
          },
        ],
      ),
      const SizedBox(height: 80),
    ];

    return ReportTabView(
      dailyContent: daily,
      weeklyContent: weekly,
      monthlyContent: monthly,
    );
  }
}
