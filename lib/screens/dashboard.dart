import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:web_app/constants/color.dart';
import 'package:web_app/constants/config.dart';
import 'package:web_app/models/review.dart';
import 'package:web_app/utils/request.dart';
import 'package:web_app/utils/stt.dart';
import 'package:web_app/widgets/button.dart';
import 'package:web_app/widgets/container.dart';
import 'package:web_app/widgets/layout.dart';
import 'package:web_app/widgets/menu.dart';
import 'package:web_app/widgets/text_field.dart';

typedef DashboardState = ValueNotifier<Map<String, dynamic>>;
typedef IDType = ValueNotifier<String?>;

class DashboardScreen extends StatelessWidget {
  static const pageRoute = "/";

  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Map<String, dynamic> initialState = {
      'pos': 0,
      'neg': 0,
      'neu': 0,
      'cnt': 0,
      'txt': 0,
      'h-score': 0,
      'h-label': 'Undefined',
    };

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardState(initialState),
        ),
        ChangeNotifierProvider(
          create: (_) => IDType(null),
        ),
      ],
      builder: ((context, child) {
        final controller = TextEditingController();

        return MyCustomLayout(
          pageRoute: pageRoute,
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: const [
                          Expanded(
                            flex: 1,
                            child: RingChartWidget(),
                          ),
                          Expanded(
                            flex: 1,
                            child: TextCountWidget(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: ReviewAnalysisWidget(
                        controller: controller,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: CardContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: ReviewsWidget(controller: controller),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class ReviewsWidget extends StatelessWidget {
  final TextEditingController controller;
  const ReviewsWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ValueNotifier<Tuple2<String, String>>(
        const Tuple2("NONE", "NONE"),
      ),
      builder: (context, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectionMenu(
            selections: const ["NONE", "POS", "NEG", "NEU"],
            onPressed: (val) =>
                context.read<ValueNotifier<Tuple2<String, String>>>().value =
                    context
                        .read<ValueNotifier<Tuple2<String, String>>>()
                        .value
                        .withItem1(val),
          ),
          const SizedBox(
            height: 20,
          ),
          SelectionMenu(
            selections: const ["NONE", "ASCD", "DESC"],
            onPressed: (val) =>
                context.read<ValueNotifier<Tuple2<String, String>>>().value =
                    context
                        .read<ValueNotifier<Tuple2<String, String>>>()
                        .value
                        .withItem2(val),
          ),
          const SizedBox(
            height: 20,
          ),
          StreamBuilder<QuerySnapshot<Object?>>(
            stream: context.read<ReviewModel>().getStream(
                filter: context
                    .watch<ValueNotifier<Tuple2<String, String>>>()
                    .value
                    .item1
                    .toLowerCase()),
            builder: (context, snapshot) {
              log("Reviews snapshot connection state == ${snapshot.connectionState}");

              if (snapshot.data?.docs.isNotEmpty ?? false) {
                List<Review> reviews = snapshot.data!.docs
                    .map((e) => Review.fromSnapshot(e))
                    .toList();

                switch (context
                    .watch<ValueNotifier<Tuple2<String, String>>>()
                    .value
                    .item2
                    .toLowerCase()) {
                  case "none":
                    break;
                  case "ascd":
                    reviews.sort(((a, b) => a.highestScorePercentage!
                        .compareTo(b.highestScorePercentage!)));
                    break;
                  case "desc":
                    reviews.sort(((b, a) => a.highestScorePercentage!
                        .compareTo(b.highestScorePercentage!)));
                    break;
                }

                return Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Reviews Shown: ${reviews.length}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        ReviewsList(
                          reviews: reviews,
                          controller: controller,
                        )
                      ]),
                );
              }

              return Expanded(
                child: Container(
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
                            "No data found",
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ReviewsList extends StatelessWidget {
  final TextEditingController controller;
  final List<Review> reviews;

  const ReviewsList({
    this.reviews = const [],
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        controller: ScrollController(),
        itemCount: reviews.length,
        separatorBuilder: (context, i) => const SizedBox(height: 15),
        itemBuilder: (context, i) {
          Review review = reviews[i];

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => {
                context.read<IDType>().value = review.id,
                context.read<DashboardState>().value = {
                  'pos': review.sentimentScore['pos'],
                  'neg': review.sentimentScore['neg'],
                  'neu': review.sentimentScore['neu'],
                  'cnt': review.nWords,
                  'txt': review.text,
                  'h-score': review.highestScorePercentage,
                  'h-label': review.highestLabel,
                },
                controller.text = review.text,
              },
              child: Container(
                height: 170,
                decoration: BoxDecoration(
                  color: kYellowColor.withOpacity(0.5),
                  borderRadius: kBorderRadius,
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          review.createdTime.toDate().toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: sentimentColors[review.highestLabel],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            review.highestScorePercentage?.toStringAsFixed(2) ??
                                '0',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      review.text,
                      textAlign: TextAlign.justify,
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ReviewAnalysisWidget extends StatefulWidget {
  final TextEditingController controller;

  const ReviewAnalysisWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<ReviewAnalysisWidget> createState() => _ReviewAnalysisWidgetState();
}

class _ReviewAnalysisWidgetState extends State<ReviewAnalysisWidget> {
  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Expanded(
              child: RoundedTextField(
                maxLines: 12,
                maxLength: 200,
                controller: widget.controller,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyIconButton(
                  icon: (context.read<SpeechToTextController>().isListening)
                      ? Icons.mic
                      : Icons.mic_off,
                  onPressed: () => {
                    setState(
                      () {
                        if (context
                            .read<SpeechToTextController>()
                            .isListening) {
                          context.read<SpeechToTextController>().stop();
                        } else {
                          context.read<SpeechToTextController>().listen(((p0) {
                            setState(() {
                              if (p0.isConfident()) {
                                widget.controller.text +=
                                    "${p0.recognizedWords} ";
                              }
                            });
                          }));
                        }
                      },
                    )
                  },
                ),
                const Expanded(child: SizedBox()),
                MyIconButton(
                  icon: Icons.clear_outlined,
                  onPressed: () {
                    context.read<IDType>().value = null;
                    context.read<DashboardState>().value = {
                      'pos': 0,
                      'neg': 0,
                      'neu': 0,
                      'cnt': 0,
                      'txt': 0,
                      'h-score': 0,
                      'h-label': 'Undefined',
                    };
                    widget.controller.clear();
                  },
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 180,
                  child: MyTextButton(
                    color: kYellowColor,
                    title: (context.watch<IDType>().value != null)
                        ? "Re-Analyze"
                        : "Analyze Now",
                    onPressed: () async {
                      String txt = widget.controller.text;

                      await context
                          .read<APIController>()
                          .predict(txt)
                          .then((sentimentPred) {
                        if (sentimentPred != null) {
                          var label = "Undefined";
                          var highest = 0.0;

                          sentimentPred.forEach((key, value) {
                            if (key != 'cnt' && key != 'txt' && key != 'id') {
                              if (value > highest) {
                                highest = value;
                                label = sentimentLabelsRev[key]!;
                              }
                            }
                          });

                          highest *= 100;

                          context.read<DashboardState>().value = {
                            'pos': sentimentPred['positive']!,
                            'neg': sentimentPred['negative']!,
                            'neu': sentimentPred['neutral']!,
                            'cnt': txt.split(' ').length,
                            'txt': txt,
                            'h-score': highest,
                            'h-label': label,
                          };
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 180,
                  child: MyTextButton(
                    title: (context.watch<IDType>().value != null)
                        ? "Update Review"
                        : "Store Review",
                    onPressed: () async {
                      var val = context.read<DashboardState>().value;

                      Review review = Review(
                        val['txt'],
                        val['cnt']?.toInt() ?? 0,
                        val['h-label'],
                        val['h-score'],
                        {
                          'pos': val['pos']?.toDouble() ?? 0.00,
                          'neg': val['neg']?.toDouble() ?? 0.00,
                          'neu': val['neu']?.toDouble() ?? 0.00,
                        },
                        Timestamp.now(),
                      );

                      log("Storing review: ${review.toString()}");

                      String? id = context.read<IDType>().value;

                      context.read<IDType>().value = null;
                      context.read<DashboardState>().value = {
                        'pos': 0,
                        'neg': 0,
                        'neu': 0,
                        'cnt': 0,
                        'txt': 0,
                        'h-score': 0,
                        'h-label': 'Undefined',
                      };
                      widget.controller.clear();

                      if (id != null) {
                        await context
                            .read<ReviewModel>()
                            .updateReview(id, review.toMap());
                      } else {
                        await context.read<ReviewModel>().addReview(review);
                      }
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TextCountWidget extends StatelessWidget {
  const TextCountWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(30),
            child: Image.asset(
              "images/search_text.png",
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${context.watch<DashboardState>().value['cnt']}",
                style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Processed Words",
                style: TextStyle(
                  fontSize: kNormalFontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withOpacity(0.5),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class RingChartWidget extends StatelessWidget {
  const RingChartWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
        ),
        child: Consumer<DashboardState>(
          builder: (context, notifier, child) {
            return Stack(
              children: [
                PieChart(
                  dataMap: {
                    "Positive": notifier.value['pos']!.toDouble(),
                    "Negative": notifier.value['neg']!.toDouble(),
                    "Neutral": notifier.value['neu']!.toDouble(),
                  },
                  colorList: const [
                    kYellowColor,
                    kTaleColor,
                    kGreyColor,
                  ],
                  chartType: ChartType.ring,
                  ringStrokeWidth: 10,
                  chartValuesOptions: const ChartValuesOptions(
                    showChartValues: false,
                  ),
                ),
                Positioned(
                  left: 90,
                  top: 50,
                  width: 100,
                  child: Column(
                    children: [
                      Text(
                        "${notifier.value['h-score'].toInt()}%",
                        style: const TextStyle(
                          fontSize: kBigTitleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        sentimentLabels[notifier.value['h-label']] ??
                            'Undefined',
                        style: TextStyle(
                          fontSize: kNormalFontSize,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
