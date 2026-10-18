class InternetPackage {
  final String id;
  final String name;
  final String speed;
  final double monthlyFee;

  InternetPackage({
    required this.id,
    required this.name,
    required this.speed,
    required this.monthlyFee,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'speed': speed,
        'monthlyFee': monthlyFee,
      };

  factory InternetPackage.fromJson(Map<String, dynamic> json) {
    return InternetPackage(
      id: json['id'] as String,
      name: json['name'] as String,
      speed: json['speed'] as String,
      monthlyFee: (json['monthlyFee'] as num).toDouble(),
    );
  }
}
