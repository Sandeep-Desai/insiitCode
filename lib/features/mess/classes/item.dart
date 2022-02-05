class MessItem {
  String name;
  String calories;
  String imageUrl;
  bool glutenFree;
  int vote;
  MessItem({
    required this.name,
    required this.calories,
    required this.imageUrl,
    this.vote = 0,
    required this.glutenFree,
  }) {
    if (imageUrl == '-') {
      imageUrl = "https://picsum.photos/300/200";
    }
  }
}
