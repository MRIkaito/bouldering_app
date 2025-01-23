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
  });

  factory GymInfo.fromJson(Map<String, dynamic> json) {
    return GymInfo(
        gymId: json['gym_id'],
        gymName: json['gym_name'],
        hpLink: json['hp_link'],
        prefecture: json['prefecture'],
        city: json['city'],
        addressLine: json['address_line'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        telNo: json['tel_no'],
        fee: json['fee'],
        minimumFee: json['minimum_fee'],
        equipmentRentalFee: json['equipment_rental_fee']);
  }

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
      'equipment_rental_fee': equipmentRentalFee
    };
  }

  List<GymInfo> parseGymInfoList(List<dynamic> jsonList) {
    return jsonList.map((json) => GymInfo.fromJson(json)).toList();
  }
}
