extension StringExtensions on String {
  String? findFirstArticle(Set<String> possibleArticles) {
    for (final article in possibleArticles) {
      if (article.endsWith("'") && startsWith(article)) {
        return article;
      } else if (startsWith("$article ")) {
        return "$article ";
      }
    }
    return null;
  }
}
