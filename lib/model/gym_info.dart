// class GymInfo {
//   final int gymId;
//   final String gymName;
//   final String hpLink;
//   final String prefecture;
//   final String city;
//   final String addressLine;
//   final double latitude;
//   final double longitude;
//   final String telNo;
//   final String fee;
//   final int minimumFee;
//   final String equipmentRentalFee;

//   GymInfo({
//     required this.gymId,
//     required this.gymName,
//     required this.hpLink,
//     required this.prefecture,
//     required this.city,
//     required this.addressLine,
//     required this.latitude,
//     required this.longitude,
//     required this.telNo,
//     required this.fee,
//     required this.minimumFee,
//     required this.equipmentRentalFee,
//   });

//   factory GymInfo.fromJson(Map<String, dynamic> json) {
//     return GymInfo(
//         gymId: json['gym_id'],
//         gymName: json['gym_name'],
//         hpLink: json['hp_link'],
//         prefecture: json['prefecture'],
//         city: json['city'],
//         addressLine: json['address_line'],
//         latitude: json['latitude'],
//         longitude: json['longitude'],
//         telNo: json['tel_no'],
//         fee: json['fee'],
//         minimumFee: json['minimum_fee'],
//         equipmentRentalFee: json['equipment_rental_fee']);
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'gym_id': gymId,
//       'gym_name': gymName,
//       'hp_link': hpLink,
//       'prefecture': prefecture,
//       'city': city,
//       'address_line': addressLine,
//       'latitude': latitude,
//       'longitude': longitude,
//       'tel_no': telNo,
//       'fee': fee,
//       'minimum_fee': minimumFee,
//       'equipment_rental_fee': equipmentRentalFee
//     };
//   }

//   List<GymInfo> parseGymInfoList(List<dynamic> jsonList) {
//     return jsonList.map((json) => GymInfo.fromJson(json)).toList();
//   }
// }
class GymInfo {
  final int gymId;
  final String gymName;
  final String hpLink;
  final String prefecture;
  final String city;
  final String addressLine;
  final double latitude;
  final double longitude;
  final String telNo;
  final String fee;
  final int minimumFee;
  final String equipmentRentalFee;
  final int ikitaiCount;
  final int boulCount;

  final bool isBoulderingGym;
  final bool isLeadGym;
  final bool isSpeedGym;
  String? sunOpen;
  String? sunClose;
  String? monOpen;
  String? monClose;
  String? tueOpen;
  String? tueClose;
  String? wedOpen;
  String? wedClose;
  String? thuOpen;
  String? thuClose;
  String? friOpen;
  String? friClose;
  String? satOpen;
  String? satClose;
  List<String>? gymPhotos;

  GymInfo({
    required this.gymId,
    required this.gymName,
    required this.hpLink,
    required this.prefecture,
    required this.city,
    required this.addressLine,
    required this.latitude,
    required this.longitude,
    required this.telNo,
    required this.fee,
    required this.minimumFee,
    required this.equipmentRentalFee,
    required this.ikitaiCount,
    required this.boulCount,
    required this.isBoulderingGym,
    required this.isLeadGym,
    required this.isSpeedGym,
    this.sunOpen,
    this.sunClose,
    this.monOpen,
    this.monClose,
    this.tueOpen,
    this.tueClose,
    this.wedOpen,
    this.wedClose,
    this.thuOpen,
    this.thuClose,
    this.friOpen,
    this.friClose,
    this.satOpen,
    this.satClose,
    this.gymPhotos,
  });

  factory GymInfo.fromJson(Map<String, dynamic> json) {
    return GymInfo(
      gymId: json['gym_id'] ?? 0,
      gymName: json['gym_name'] ?? '-',
      hpLink: json['hp_link'] ?? '-',
      prefecture: json['prefecture'] ?? '-',
      city: json['city'] ?? '-',
      addressLine: json['address_line'] ?? '-',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      telNo: json['tel_no'] ?? '-',
      fee: json['fee'] ?? '-',
      minimumFee: json['minimum_fee'] ?? 0,
      equipmentRentalFee: json['equipment_rental_fee'] ?? '-',
      ikitaiCount: json['ikitai_count'] ?? 0,
      boulCount: json['boul_count'] ?? 0,
      isBoulderingGym: json['is_bouldering_type'] ?? true,
      isLeadGym: json['is_lead_gym'] ?? false,
      isSpeedGym: json['is_speed_gym'] ?? false,
      sunOpen: json['sun_open'] ?? '-',
      sunClose: json['sun_close'] ?? '-',
      monOpen: json['mon_open'] ?? '-',
      monClose: json['mon_close'] ?? '-',
      tueOpen: json['tue_open'] ?? '-',
      tueClose: json['tue_close'] ?? '-',
      wedOpen: json['wed_open'] ?? '-',
      wedClose: json['wed_close'] ?? '-',
      thuOpen: json['thu_open'] ?? '-',
      thuClose: json['thu_close'] ?? '-',
      friOpen: json['fir_open'] ?? '-',
      friClose: json['fri_close'] ?? '-',
      satOpen: json['sat_open'] ?? '-',
      satClose: json['sat_close'] ?? '-',
      gymPhotos: json['gym_photos'],
    );
  }

  // TODO：使う余地があれば、下記の実装も変更する
  Map<String, dynamic> toJson() {
    return {
      'gym_id': gymId,
      'gym_name': gymName,
      'hp_link': hpLink,
      'prefecture': prefecture,
      'city': city,
      'address_line': addressLine,
      'latitude': latitude,
      'longitude': longitude,
      'tel_no': telNo,
      'fee': fee,
      'minimum_fee': minimumFee,
      'equipment_rental_fee': equipmentRentalFee,
      'ikitai_count': ikitaiCount,
      'boul_count': boulCount,
    };
  }

  List<GymInfo> parseGymInfoList(List<dynamic> jsonList) {
    return jsonList.map((json) => GymInfo.fromJson(json)).toList();
  }
}
