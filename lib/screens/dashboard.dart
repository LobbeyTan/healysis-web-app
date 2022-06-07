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

class DashboardScreen extends StatelessWidget {
  static const pageRoute = "/";

  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ValueNotifier<Map<String, num>>({
        'pos': 0,
        'neg': 0,
        'neu': 0,
        'cnt': 0,
      }),
      builder: ((context, child) => MyCustomLayout(
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
                      const Expanded(
                        flex: 7,
                        child: ReviewAnalysisWidget(),
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 3,
                  child: CardContainer(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: ReviewsWidget(),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class ReviewsWidget extends StatelessWidget {
  const ReviewsWidget({
    Key? key,
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
                        ReviewsList(reviews: reviews)
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
  final List<Review> reviews;

  const ReviewsList({
    this.reviews = const [],
    Key? key,
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

          return Container(
            height: 170,
            padding: const EdgeInsets.all(10),
            child: Column(
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
          );
        },
      ),
    );
  }
}

class ReviewAnalysisWidget extends StatefulWidget {
  const ReviewAnalysisWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<ReviewAnalysisWidget> createState() => _ReviewAnalysisWidgetState();
}

class _ReviewAnalysisWidgetState extends State<ReviewAnalysisWidget> {
  final TextEditingController controller = TextEditingController();

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
                controller: controller,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Material(
                  color: kPrimaryColor,
                  clipBehavior: Clip.hardEdge,
                  shape: const CircleBorder(),
                  child: IconButton(
                    iconSize: 25,
                    padding: const EdgeInsets.all(15),
                    color: Colors.white,
                    onPressed: () => {
                      setState(
                        () {
                          if (context
                              .read<SpeechToTextController>()
                              .isListening) {
                            context.read<SpeechToTextController>().stop();
                          } else {
                            context
                                .read<SpeechToTextController>()
                                .listen(((p0) {
                              setState(() {
                                if (p0.isConfident()) {
                                  controller.text += "${p0.recognizedWords} ";
                                }
                              });
                            }));
                          }
                        },
                      )
                    },
                    icon: context.read<SpeechToTextController>().isListening
                        ? const Icon(Icons.mic)
                        : const Icon(Icons.mic_off),
                  ),
                ),
                const Expanded(child: SizedBox()),
                MyTextButton(
                  color: kYellowColor,
                  title: "Anlayze Now",
                  onPressed: () async {
                    await context
                        .read<APIController>()
                        .predict(controller.text)
                        .then((sentimentPred) {
                      if (sentimentPred != null) {
                        context.read<ValueNotifier<Map<String, num>>>().value =
                            {
                          'pos': sentimentPred['positive']!,
                          'neg': sentimentPred['negative']!,
                          'neu': sentimentPred['neutral']!,
                          'cnt': controller.text.split(' ').length,
                        };
                      }
                    });
                  },
                ),
                const SizedBox(width: 20),
                MyTextButton(
                  title: "Store Review",
                  onPressed: () async {
                    var val =
                        context.read<ValueNotifier<Map<String, num>>>().value;

                    var highestLabel = "";
                    var highestScorePercentage = 0.0;

                    val.forEach((key, value) {
                      if (key != 'cnt') {
                        if (value > highestScorePercentage) {
                          highestScorePercentage = value.toDouble();
                          highestLabel = key;
                        }
                      }
                    });

                    highestScorePercentage *= 100;

                    Review review = Review(
                        controller.text,
                        val['cnt']?.toInt() ?? 0,
                        highestLabel,
                        highestScorePercentage,
                        {
                          'pos': val['pos']?.toDouble() ?? 0.00,
                          'neg': val['neg']?.toDouble() ?? 0.00,
                          'neu': val['neu']?.toDouble() ?? 0.00,
                        },
                        Timestamp.now());

                    log("Storing review: ${review.toString()}");
                    await context.read<ReviewModel>().addReview(review);
                  },
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
                "${context.watch<ValueNotifier<Map<String, num>>>().value['cnt']}",
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
        child: Consumer<ValueNotifier<Map<String, num>>>(
          builder: (context, notifier, child) {
            var label = "Undefined";
            var highest = 0.0;

            notifier.value.forEach((key, value) {
              if (key != 'cnt') {
                if (value > highest) {
                  highest = value.toDouble() * 100;
                  label = sentimentLabels[key]!;
                }
              }
            });

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
                        "${highest.toInt()}%",
                        style: const TextStyle(
                          fontSize: kBigTitleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        label,
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
