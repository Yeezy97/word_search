class WordEntry {
  final String lemma;
  final String definition;

  WordEntry({required this.lemma, required this.definition});

  @override
  String toString() => '$lemma: $definition';
}