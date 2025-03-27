class LetterModel {
  final String letter;
  final int index; // Used to differentiate duplicate letters
  LetterModel({required this.letter, required this.index});

  String get uniqueKey => "${letter}_$index";
}
