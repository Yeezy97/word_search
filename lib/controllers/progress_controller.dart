import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:word_search/controllers/auth_controller.dart';

class ProgressController extends GetxController {
  final _db   = FirebaseFirestore.instance;
  final auth  = Get.find<AuthController>();
  final score = 0.obs;
  final level = 1.obs;
  final rank  = 0.obs;

  StreamSubscription? _sub;

  @override
  void onInit() {
    super.onInit();
    ever(auth.firebaseUser, _onAuthChanged);
  }

  void _onAuthChanged(User? u) {
    _sub?.cancel();
    if (u != null) {
      _sub = _db
          .collection('users')
          .doc(u.uid)
          .snapshots()
          .listen((snap) async {
        if (snap.exists) {
          score.value = snap['score']  ?? 0;
          level.value = snap['level']  ?? 1;
          await _updateRank();
        } else {
          await _db.collection('users').doc(u.uid).set({'score':0,'level':1});
        }
      });
    } else {
      score.value = 0;
      level.value = 1;
      rank.value  = 0;
    }
  }

  Future<void> _updateRank() async {
    final user = auth.firebaseUser.value;
    final uid = user?.uid;
    final qs = await _db
        .collection('users')
        .where('score', isGreaterThan: score.value)
        .get();
    rank.value = qs.size + 1;
  }

  Future<void> updateProgress({required int newLevel, int addScore = 50}) {
    final user = auth.firebaseUser.value;
    if (user == null) return Future.value();
    final uid = user.uid;
    final newScore = score.value + addScore;
    return _db
        .collection('users')
        .doc(uid)
        .set({'score': newScore, 'level': newLevel}, SetOptions(merge:true));
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
