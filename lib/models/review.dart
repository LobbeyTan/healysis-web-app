import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Review {
  String? id;
  String text;
  int nWords;
  String? highestLabel;
  double? highestScorePercentage;
  Map<String, double> sentimentScore;
  Timestamp createdTime;

  Review(
    this.text,
    this.nWords,
    this.highestLabel,
    this.highestScorePercentage,
    this.sentimentScore,
    this.createdTime, {
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'nWords': nWords,
      'highestLabel': highestLabel,
      'highestScorePercentage': highestScorePercentage,
      'sentimentScore': sentimentScore,
      'createdTime': createdTime.microsecondsSinceEpoch,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map, {String? id}) {
    return Review(
      map['text'] ?? '',
      map['nWords']?.toInt() ?? 0,
      map['highestLabel'],
      map['highestScorePercentage']?.toDouble(),
      Map<String, double>.from(map['sentimentScore']),
      Timestamp.fromMicrosecondsSinceEpoch(map['createdTime']),
      id: id,
    );
  }

  String toJson() => json.encode(toMap());

  factory Review.fromJson(String source) => Review.fromMap(json.decode(source));

  factory Review.fromSnapshot(DocumentSnapshot snapshot) => Review.fromMap(
        snapshot.data()! as Map<String, dynamic>,
        id: snapshot.id,
      );

  @override
  String toString() {
    return 'Review(text: $text, nWords: $nWords, highestLabel: $highestLabel, highestScorePercentage: $highestScorePercentage, sentimentScore: $sentimentScore, createdTime: $createdTime)';
  }

  Review copyWith({
    String? text,
    int? nWords,
    String? highestLabel,
    double? highestScorePercentage,
    Map<String, double>? sentimentScore,
    Timestamp? createdTime,
  }) {
    return Review(
      text ?? this.text,
      nWords ?? this.nWords,
      highestLabel ?? this.highestLabel,
      highestScorePercentage ?? this.highestScorePercentage,
      sentimentScore ?? this.sentimentScore,
      createdTime ?? this.createdTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Review &&
        other.text == text &&
        other.nWords == nWords &&
        other.highestLabel == highestLabel &&
        other.highestScorePercentage == highestScorePercentage &&
        mapEquals(other.sentimentScore, sentimentScore) &&
        other.createdTime == createdTime;
  }

  @override
  int get hashCode {
    return text.hashCode ^
        nWords.hashCode ^
        highestLabel.hashCode ^
        highestScorePercentage.hashCode ^
        sentimentScore.hashCode ^
        createdTime.hashCode;
  }
}

class ReviewModel {
  static late final CollectionReference collection;

  ReviewModel({required FirebaseFirestore firestore}) {
    collection = firestore.collection('reviews');
  }

  Future<Review?> getReview(String id) async {
    try {
      return Review.fromSnapshot(await collection.doc(id).get());
    } catch (e) {
      log("Retrieve review error", error: e);
    }

    return null;
  }

  Future<DocumentReference?> addReview(Review review) async {
    DocumentReference? ref;

    await collection.add(review.toMap()).then((value) {
      ref = value;
      log("Review added successfully: ${value.id}");
    }).onError((error, errorStack) {
      log("Failed to add review: $error\n$errorStack", error: error);
    });

    return ref;
  }

  Future<void> updateReview(String id, Map<String, Object?> newData) async {
    await collection
        .doc(id)
        .update(newData)
        .then((value) => log("Successfully updated review $id"))
        .catchError(
          (error) => log("Failed to update review $id: $error", error: error),
        );
  }

  Future<void> deleteReview(String id) async {
    await collection
        .doc(id)
        .delete()
        .then((value) => log("Successfully delete review $id"))
        .catchError(
          (error) => log("Failed to delete review $id: $error", error: error),
        );
  }

  Stream<QuerySnapshot<Object?>> getStream({
    String field = "highestLabel",
    String filter = "none",
  }) {
    if (filter == "none") {
      return collection
          .orderBy("createdTime", descending: true)
          .limit(100)
          .snapshots();
    } else {
      return collection.where(field, isEqualTo: filter).limit(100).snapshots();
    }
  }

  Future<List<Review>> getReviewInRange(Timestamp start, Timestamp end) async {
    return (await collection
            .where("created", isGreaterThan: start)
            .where("created", isLessThan: end)
            .get())
        .docs
        .map((e) => Review.fromSnapshot(e))
        .toList();
  }
}
