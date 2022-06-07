import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:web_app/constants/color.dart';
import 'package:web_app/constants/config.dart';
import 'package:web_app/constants/data.dart';
import 'package:web_app/utils/storage.dart';
import 'package:web_app/widgets/container.dart';
import 'package:web_app/widgets/layout.dart';

class DatasetScreen extends StatelessWidget {
  static const pageRoute = "/dataset";

  const DatasetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MyCustomLayout(
      pageRoute: pageRoute,
      child: DatasetScreenBody(),
    );
  }
}

class DatasetScreenBody extends StatelessWidget {
  const DatasetScreenBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ValueNotifier<Tuple2<int, Uint8List?>>(const Tuple2(-1, null)),
      builder: (context, child) => Row(
        children: [
          Expanded(
            flex: 3,
            child: CardContainer(
              contentPadding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Dataset Used",
                    style: TextStyle(
                      fontSize: kBigTitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child:
                        FutureBuilder<List<Tuple2<Uint8List?, FullMetadata>>>(
                      future: context
                          .read<StorageController>()
                          .getAllDatasetPreviews(),
                      builder: ((context, snapshot) {
                        if (snapshot.data?.isNotEmpty ?? false) {
                          return Consumer<
                              ValueNotifier<Tuple2<int, Uint8List?>>>(
                            builder: (context, notifier, child) {
                              return ListView.separated(
                                controller: ScrollController(),
                                itemBuilder: (context, i) {
                                  var data = snapshot.data![i];

                                  return FileCard(
                                    metadata: data,
                                    color: kYellowColor.withOpacity(
                                      notifier.value.item1 == i ? 1 : 0.3,
                                    ),
                                    originalSize: originalDatasetSize[i],
                                    onPressed: () => notifier.value =
                                        Tuple2(i, snapshot.data![i].item1),
                                  );
                                },
                                separatorBuilder: (_, i) => const SizedBox(
                                  height: 10,
                                ),
                                itemCount: snapshot.data!.length,
                              );
                            },
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
                          child: snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? const SpinKitPouringHourGlass(
                                  color: kPrimaryColor,
                                )
                              : const Center(
                                  child: Text(
                                    "No data found",
                                  ),
                                ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: CardContainer(
              contentPadding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Previews",
                    style: TextStyle(
                      fontSize: kBigTitleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: Consumer<ValueNotifier<Tuple2<int, Uint8List?>>>(
                      builder: (context, notifier, child) => DatasetPreview(
                        data: notifier.value.item2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DatasetPreview extends StatelessWidget {
  final _horizontalScrollController = ScrollController();
  final _verticalScrollController = ScrollController();

  final Uint8List? data;

  DatasetPreview({
    Key? key,
    this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 3,
          color: kGreyColor,
        ),
      ),
      child: data == null
          ? Center(
              child: Text(
                "No Dataset Selected",
                style: TextStyle(
                  fontSize: kNormalFontSize,
                  color: Colors.black.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Scrollbar(
              thumbVisibility: true,
              controller: _horizontalScrollController,
              child: ListView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                children: [
                  SizedBox(
                    width: 1500,
                    child: ListView(
                      controller: _verticalScrollController,
                      children: [buildTable()],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Table buildTable() {
    bool isHeader = true;

    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(flex: 1),
      children: Excel.decodeBytes(data!)
          .tables
          .values
          .first
          .rows
          .map<TableRow>((rowData) {
        var tableRow = TableRow(
          decoration: BoxDecoration(
            color: isHeader ? kYellowColor : Colors.white,
            border: Border(
              bottom: BorderSide(width: isHeader ? 3 : 1),
            ),
          ),
          children: rowData
              .map<Widget>(
                (e) => TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      e?.value.toString() ?? "NaN",
                      style: TextStyle(
                        fontSize: isHeader ? 15 : 14,
                        fontWeight:
                            isHeader ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        );

        isHeader = false;
        return tableRow;
      }).toList(),
    );
  }
}

class FileCard extends StatefulWidget {
  final double originalSize;
  final Color color;
  final VoidCallback? onPressed;
  final Tuple2<Uint8List?, FullMetadata> metadata;

  const FileCard({
    Key? key,
    this.onPressed,
    required this.metadata,
    required this.originalSize,
    required this.color,
  }) : super(key: key);

  @override
  State<FileCard> createState() => _FileCardState();
}

class _FileCardState extends State<FileCard> {
  late Color _color;

  @override
  void initState() {
    _color = widget.color;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FileCard oldWidget) {
    _color = widget.color;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (event) {
        setState(
          () {
            _color = kPrimaryColor.withOpacity(0.5);
          },
        );
      },
      onExit: (event) {
        setState(() {
          _color = widget.color;
        });
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.metadata.item2.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Image.asset(
                    "images/excel.png",
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Preview size: ${(widget.metadata.item2.size! / 1024).toStringAsFixed(2)} KB",
                        ),
                        Text(
                          "Original size: ${widget.originalSize.toStringAsFixed(2)} MB",
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
