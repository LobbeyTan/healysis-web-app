import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:web_app/constants/color.dart';
import 'package:web_app/constants/config.dart';
import 'package:web_app/constants/data.dart';
import 'package:web_app/utils/request.dart';
import 'package:web_app/widgets/container.dart';
import 'package:web_app/widgets/indicator.dart';
import 'package:web_app/widgets/layout.dart';
import 'package:web_app/widgets/rounded_dropdown.dart';

class AnalyticScreen extends StatelessWidget {
  static const pageRoute = "/analytic";

  const AnalyticScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyCustomLayout(
      pageRoute: pageRoute,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Reviews Analysis Dashboard",
                  style: TextStyle(
                    fontSize: kBigTitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownMenu(
                    items: [
                      "Past 1 week",
                      "Past 2 weeks",
                      "Past 1 month",
                      "Past 3 month",
                      "All the time",
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: context.read<APIController>().getAnalysis(),
              builder: (context, snapshot) {
                if (snapshot.data != null &&
                    (snapshot.data?.isNotEmpty ?? false)) {
                  return Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: CardContainer(
                                child: SentimentValuePieChart(
                                  data: (snapshot.data!['average_sentiment']!
                                          as Map<String, dynamic>)
                                      .map((key, value) =>
                                          MapEntry(key, value as double)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: CardContainer(
                                child: ReviewsCountLineChart(
                                  reviewCount:
                                      (snapshot.data!['counts_per_day']!
                                              as List<dynamic>)
                                          .map((e) => e as int)
                                          .toList(),
                                ),
                              ),
                            ),
                            Expanded(
                              child: CardContainer(
                                child: SentimentDistributionLineChart(
                                    distribution: (snapshot.data![
                                                "sentiment_distribution_per_day"]!
                                            as Map<String, dynamic>)
                                        .map((key, value) => MapEntry(
                                            key,
                                            (value as List<dynamic>)
                                                .map((e) => e as double)
                                                .toList()))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: CardContainer(
                                child: Top30Words(
                                  maxY: 80,
                                  title: "Top 15 Positive Emotion Words",
                                  data: top30Positive,
                                ),
                              ),
                            ),
                            Expanded(
                              child: CardContainer(
                                child: Top30Words(
                                  maxY: 1500,
                                  title: "Top 15 Negative Emotion Words",
                                  data: top30Negative,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 3,
                      color: kGreyColor,
                    ),
                  ),
                  child: snapshot.connectionState == ConnectionState.waiting
                      ? const SpinKitPouringHourGlass(
                          color: kPrimaryColor,
                        )
                      : const Center(
                          child: Text(
                            "Failed to get analyzed data.\nPlease make sure the server is up.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: kNormalFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Top30Words extends StatelessWidget {
  final int length;
  final double? maxY;
  final String title;
  final List<List<dynamic>> data;

  const Top30Words({
    Key? key,
    required this.title,
    required this.data,
    this.maxY,
    this.length = 15,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: kNormalFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: BarChart(
                    BarChartData(
                      barTouchData: barTouchData,
                      titlesData: titlesData,
                      borderData: borderData,
                      barGroups: barGroups,
                      gridData: FlGridData(show: false),
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 30),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: ListView(
                      controller: ScrollController(),
                      children: List.generate(
                        length,
                        (i) => Text(
                          "${i + 1} - ${data[i][0]}",
                          overflow: TextOverflow.visible,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: const EdgeInsets.all(0),
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4.0,
      child: Text("${value.toInt() + 1}", style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  final _barsGradient = const LinearGradient(
    colors: [
      Colors.lightBlueAccent,
      Colors.greenAccent,
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  List<BarChartGroupData> get barGroups => List.generate(
        length,
        (i) => BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: data[i][1],
              gradient: _barsGradient,
            )
          ],
          showingTooltipIndicators: [0],
        ),
      );

  // List<BarChartGroupData> get barGroups => [
  //       BarChartGroupData(
  //         x: 0,
  //         barRods: [
  //           BarChartRodData(
  //             toY: 8,
  //             gradient: _barsGradient,
  //           )
  //         ],
  //         showingTooltipIndicators: [0],
  //       ),
  //       BarChartGroupData(
  //         x: 1,
  //         barRods: [
  //           BarChartRodData(
  //             toY: 10,
  //             gradient: _barsGradient,
  //           )
  //         ],
  //         showingTooltipIndicators: [0],
  //       ),
  //       BarChartGroupData(
  //         x: 2,
  //         barRods: [
  //           BarChartRodData(
  //             toY: 14,
  //             gradient: _barsGradient,
  //           )
  //         ],
  //         showingTooltipIndicators: [0],
  //       ),
  //       BarChartGroupData(
  //         x: 3,
  //         barRods: [
  //           BarChartRodData(
  //             toY: 15,
  //             gradient: _barsGradient,
  //           )
  //         ],
  //         showingTooltipIndicators: [0],
  //       ),
  //       BarChartGroupData(
  //         x: 3,
  //         barRods: [
  //           BarChartRodData(
  //             toY: 13,
  //             gradient: _barsGradient,
  //           )
  //         ],
  //         showingTooltipIndicators: [0],
  //       ),
  //       BarChartGroupData(
  //         x: 3,
  //         barRods: [
  //           BarChartRodData(
  //             toY: 10,
  //             gradient: _barsGradient,
  //           )
  //         ],
  //         showingTooltipIndicators: [0],
  //       ),
  //     ];
}

class SentimentDistributionLineChart extends StatelessWidget {
  final Map<String, List<double>> distribution;

  const SentimentDistributionLineChart({
    Key? key,
    required this.distribution,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Sentiment Distribution",
              style: TextStyle(
                fontSize: kNormalFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: LineChart(sampleData)),
        ],
      ),
    );
  }

  LineChartData get sampleData => LineChartData(
        lineTouchData: lineTouchData,
        gridData: gridData,
        titlesData: titlesData,
        borderData: borderData,
        lineBarsData: lineBarsData,
        minX: 0,
        minY: 0,
        maxX: 6,
        maxY: 1.1,
      );

  LineTouchData get lineTouchData => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: kPrimaryColor.withOpacity(0.8),
        ),
      );

  FlTitlesData get titlesData => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  List<LineChartBarData> get lineBarsData => [
        lineChartBarData1,
        lineChartBarData2,
        lineChartBarData3,
      ];

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff75729e),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    switch ((value * 10).toInt()) {
      case 0:
        text = '0.0';
        break;
      case 2:
        text = '0.2';
        break;
      case 4:
        text = '0.4';
        break;
      case 6:
        text = '0.6';
        break;
      case 8:
        text = '0.8';
        break;
      case 10:
        text = '1.0';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: false,
        // interval: 0.2,
        // reservedSize: 30,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('Mon', style: style);
        break;
      case 1:
        text = const Text('Tue', style: style);
        break;
      case 2:
        text = const Text('Wed', style: style);
        break;
      case 3:
        text = const Text('Thu', style: style);
        break;
      case 4:
        text = const Text('Fri', style: style);
        break;
      case 5:
        text = const Text('Sat', style: style);
        break;
      case 6:
        text = const Text('Sun', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 30,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  FlGridData get gridData => FlGridData(
        show: true,
        horizontalInterval: 0.1,
      );

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color(0xff4e4965), width: 2),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData get lineChartBarData1 => LineChartBarData(
        isCurved: true,
        color: kYellowColor,
        barWidth: 5,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: distribution['pos']!
            .asMap()
            .entries
            .map((e) => FlSpot(
                e.key.toDouble(), double.parse(e.value.toStringAsFixed(2))))
            .toList(),
      );

  LineChartBarData get lineChartBarData2 => LineChartBarData(
        isCurved: true,
        color: kTaleColor,
        barWidth: 5,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: false,
          color: const Color(0x00aa4cfc),
        ),
        spots: distribution['neg']!
            .asMap()
            .entries
            .map((e) => FlSpot(
                e.key.toDouble(), double.parse(e.value.toStringAsFixed(2))))
            .toList(),
      );

  LineChartBarData get lineChartBarData3 => LineChartBarData(
        isCurved: true,
        color: Colors.grey[700],
        barWidth: 5,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: distribution['neu']!
            .asMap()
            .entries
            .map((e) => FlSpot(
                e.key.toDouble(), double.parse(e.value.toStringAsFixed(2))))
            .toList(),
      );
}

class ReviewsCountLineChart extends StatefulWidget {
  final List<int> reviewCount;

  const ReviewsCountLineChart({
    Key? key,
    required this.reviewCount,
  }) : super(key: key);

  @override
  State<ReviewsCountLineChart> createState() => _ReviewsCountLineChartState();
}

class _ReviewsCountLineChartState extends State<ReviewsCountLineChart> {
  final List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Total Number of Reviews",
              style: TextStyle(
                fontSize: kNormalFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: LineChart(mainData())),
        ],
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('Mon', style: style);
        break;
      case 1:
        text = const Text('Tue', style: style);
        break;
      case 2:
        text = const Text('Wed', style: style);
        break;
      case 3:
        text = const Text('Thu', style: style);
        break;
      case 4:
        text = const Text('Fri', style: style);
        break;
      case 5:
        text = const Text('Sat', style: style);
        break;
      case 6:
        text = const Text('Sun', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 10:
        text = '10';
        break;
      case 30:
        text = '30';
        break;
      case 50:
        text = '50';
        break;
      case 70:
        text = '70';
        break;
      case 90:
        text = '90';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: (value.toInt() % 10 == 0) ? 1 : 0,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 30,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: const Color(0xff37434d),
          width: 1,
        ),
      ),
      minX: 0,
      maxX: 6,
      minY: 30,
      maxY: 100,
      lineBarsData: [
        LineChartBarData(
          spots: widget.reviewCount
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
              .toList(),
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ],
    );
  }
}

class SentimentValuePieChart extends StatefulWidget {
  final Map<String, double> data;

  const SentimentValuePieChart({
    required this.data,
    Key? key,
  }) : super(key: key);

  @override
  State<SentimentValuePieChart> createState() => _SentimentValuePieChartState();
}

class _SentimentValuePieChartState extends State<SentimentValuePieChart> {
  final List<String> sentimentTitles = ['Positive', 'Negative', 'Neutral'];
  final List<String> sentimentLabels = ['pos', 'neg', 'neu'];
  final List<Color> sentimentColors = [kYellowColor, kTaleColor, kGreyColor];

  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Sentiment Distribution",
              style: TextStyle(
                fontSize: kNormalFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 0,
                      sections: showingSections(),
                      pieTouchData: PieTouchData(
                        enabled: true,
                        touchCallback: (FlTouchEvent event,
                            PieTouchResponse? pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                            } else {
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      sentimentTitles.length,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Indicator(
                          color: sentimentColors[i],
                          text: sentimentTitles[i],
                          size: i == touchedIndex ? 22 : 18,
                          isSquare: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(sentimentColors.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 110.0 : 100.0;

      final style = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: const Color(0xff68737d),
      );

      return PieChartSectionData(
        color: sentimentColors[i],
        value: widget.data[sentimentLabels[i]],
        title: '${widget.data[sentimentLabels[i]]!.toStringAsFixed(2)}%',
        radius: radius,
        titleStyle: style,
        titlePositionPercentageOffset: 0.6,
      );
    });
  }
}
