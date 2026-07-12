class ProfileEntry {
  const ProfileEntry({
    required this.title,
    required this.place,
    required this.year,
  });

  final String title;  
  final String place;  
  final String year;   

  Map<String, dynamic> toMap() => {
        'title': title,
        'place': place,
        'year': year,
      };

  factory ProfileEntry.fromMap(Map<String, dynamic> map) => ProfileEntry(
        title: map['title'] as String? ?? '',
        place: map['place'] as String? ?? '',
        year: map['year'] as String? ?? '',
      );
}