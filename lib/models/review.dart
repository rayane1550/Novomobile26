class RestaurantReview {
  const RestaurantReview({
    required this.id,
    required this.author,
    required this.comment,
    required this.rating,
    this.likes = 0,
    this.likedByMe = false,
  });

  final int id;
  final String author;
  final String comment;
  final int rating;
  final int likes;
  final bool likedByMe;

  RestaurantReview copyWith({
    int? id,
    String? author,
    String? comment,
    int? rating,
    int? likes,
    bool? likedByMe,
  }) {
    return RestaurantReview(
      id: id ?? this.id,
      author: author ?? this.author,
      comment: comment ?? this.comment,
      rating: rating ?? this.rating,
      likes: likes ?? this.likes,
      likedByMe: likedByMe ?? this.likedByMe,
    );
  }
}
