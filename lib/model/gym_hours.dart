class GymHours {
  final int gymId;
  final DateTime sunOpen;
  final DateTime sunClose;
  final DateTime monOpen;
  final DateTime monClose;
  final DateTime tueOpen;
  final DateTime tueClose;
  final DateTime wedOpen;
  final DateTime wedClose;
  final DateTime thuOpen;
  final DateTime thuClose;
  final DateTime friOpen;
  final DateTime friClose;
  final DateTime satOpen;
  final DateTime satClose;

  GymHours(
      {required this.gymId,
      required this.sunOpen,
      required this.sunClose,
      required this.monOpen,
      required this.monClose,
      required this.tueOpen,
      required this.tueClose,
      required this.wedOpen,
      required this.wedClose,
      required this.thuOpen,
      required this.thuClose,
      required this.friOpen,
      required this.friClose,
      required this.satOpen,
      required this.satClose});

  // JSON形式からGymHoursクラス(Map形式)への変換
  factory GymHours.fromJson(Map<String, dynamic> json) {
    return GymHours(
        gymId: json['gym_id'],
        sunOpen: json['sun_open'],
        sunClose: json['sun_close'],
        monOpen: json['mon_open'],
        monClose: json['mon_close'],
        tueOpen: json['tue_open'],
        tueClose: json['tue_close'],
        wedOpen: json['wed_open'],
        wedClose: json['wed_close'],
        thuOpen: json['thu_open'],
        thuClose: json['thu_close'],
        friOpen: json['fri_open'],
        friClose: json['fri_close'],
        satOpen: json['sat_open'],
        satClose: json['sat_close']);
  }

  // GymHoursクラスからJSON形式編の変換
  Map<String, dynamic> toJson() {
    return {
      'gym_id': gymId,
      'sun_open': sunOpen,
      'sun_close': sunClose,
      'mon_open': monOpen,
      'mon_close': monClose,
      'tue_open': sunOpen,
      'tue_close': sunClose,
      'wed_open': sunOpen,
      'wed_close': sunClose,
      'thu_open': sunOpen,
      'thu_close': sunClose,
      'fri_open': sunOpen,
      'fri_close': sunClose,
      'sat_open': sunOpen,
      'sat_close': sunClose
    };
  }

  // ヘルパー関数：List<dynamic> → List<GymHours>に変換
  List<GymHours> parseGymhoursList(List<dynamic> jsonList) {
    return jsonList.map((json) => GymHours.fromJson(json)).toList();
  }
}
