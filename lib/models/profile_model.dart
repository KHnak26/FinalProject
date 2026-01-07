class ProfileModel {
  final String name;
  final String sex;
  final DateTime dob;
  final double weightKg;
  final double heightCm;

  ProfileModel({
    required this.name,
    required this.sex,
    required this.dob,
    required this.weightKg,
    required this.heightCm,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        name: json['name'] as String,
        sex: json['sex'] as String,
      dob: DateTime.parse(json['dob'] as String),
      weightKg: (json['weightKg'] as num).toDouble(),
      heightCm: (json['heightCm'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'sex': sex,
      'dob': dob.toIso8601String(),
      'weightKg': weightKg,
      'heightCm': heightCm,
      };
}
