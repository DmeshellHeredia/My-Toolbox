class RandomPerson {
  final String firstName;
  final String lastName;
  final String photoUrl;
  final DateTime birthDate;
  final int age;

  const RandomPerson({
    required this.firstName,
    required this.lastName,
    required this.photoUrl,
    required this.birthDate,
    required this.age,
  });

  String get fullName => '$firstName $lastName';

  factory RandomPerson.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as Map<String, dynamic>;
    final dob = json['dob'] as Map<String, dynamic>;
    final picture = json['picture'] as Map<String, dynamic>;

    return RandomPerson(
      firstName: name['first'] as String,
      lastName: name['last'] as String,
      photoUrl: picture['large'] as String,
      birthDate: DateTime.parse(dob['date'] as String),
      age: (dob['age'] as num).toInt(),
    );
  }
}
