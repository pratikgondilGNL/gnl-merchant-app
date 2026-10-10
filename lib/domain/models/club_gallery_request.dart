class ClubGalleryRequest {
  final List<String> images;
  final String reviewPoints;
  final bool isPrimary;

  const ClubGalleryRequest({
    required this.images,
    required this.reviewPoints,
    this.isPrimary = false,
  });

  Map<String, dynamic> toJson() => {
    'images': images,
    'review_points': reviewPoints,
    'is_primary': isPrimary,
  };
}
