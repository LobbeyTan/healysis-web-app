import 'dart:developer';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:tuple/tuple.dart';

class StorageController {
  late final FirebaseStorage firebaseStorage;

  StorageController() {
    firebaseStorage = FirebaseStorage.instance;
  }

  Future<List<Tuple2<Uint8List?, FullMetadata>>> getAllDatasetPreviews() async {
    List<String> filenames = [
      "all_gp_comments",
      "gp_comments_and_responses",
      "hospital_comments_report",
      "preprocessed_dataset"
    ];

    List<Tuple2<Uint8List?, FullMetadata>> data = [];

    try {
      for (String x in filenames) {
        var tuple = getDatasetPreviews(filename: x);

        var dataset = await tuple.item1;

        var metadata = await tuple.item2;

        data.add(Tuple2<Uint8List?, FullMetadata>(dataset, metadata));
      }
    } on FirebaseException catch (e) {
      log(e.toString(), error: e);
    } on Exception catch (e) {
      log(e.toString(), error: e);
    }

    return data;
  }

  Tuple2<Future<Uint8List?>, Future<FullMetadata>> getDatasetPreviews(
      {required String filename}) {
    Reference ref = firebaseStorage.ref("previews/$filename.xlsx");

    return Tuple2(ref.getData(), ref.getMetadata());
  }
}
