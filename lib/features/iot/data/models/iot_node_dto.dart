import '../../domain/models/iot_node.dart';

class IotNodeDto {
  static IotNode fromJson(Map<String, dynamic> json) {
    return IotNode(
      id: json['id'] is int ? json['id'] : (json['id'] as num?)?.toInt() ?? 0,
      nodeCode: json['nodeCode']?.toString() ?? '',
      status: json['status']?.toString() ?? 'OFFLINE',
      plantId: json['plantId'] is int
          ? json['plantId']
          : (json['plantId'] as num?)?.toInt() ?? 0,
      profileId: json['profileId'] is int
          ? json['profileId']
          : (json['profileId'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}
