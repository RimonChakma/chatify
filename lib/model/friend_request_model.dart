enum FriendRequestStatus { pending, accepted, declined }

class FriendRequestModel {
  final String id;
  final String senderId;
  final String receivedId;
  final FriendRequestStatus status;
  final DateTime createdAt;
  final DateTime? responseAt;
  final String? message;

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.receivedId,
    this.status = FriendRequestStatus.pending,
    required this.createdAt,
    this.responseAt,
    this.message,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receivedId': receivedId,
      'status': status.index, // enum to int
      'createdAt': createdAt.millisecondsSinceEpoch,
      'responseAt': responseAt?.millisecondsSinceEpoch,
      'message': message,
    };
  }

  // Convert from Map
  static FriendRequestModel fromMap(Map<String, dynamic> map) {
    return FriendRequestModel(
      id: map['id'],
      senderId: map['senderId'],
      receivedId: map['receivedId'],
      status: FriendRequestStatus.values[map['status'] ?? 0],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      responseAt: map['responseAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['responseAt'] as int)
          : null,
      message: map['message'],
    );
  }

  // copyWith
  FriendRequestModel copyWith({
    String? id,
    String? senderId,
    String? receivedId,
    FriendRequestStatus? status,
    DateTime? createdAt,
    DateTime? responseAt,
    String? message,
  }) {
    return FriendRequestModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receivedId: receivedId ?? this.receivedId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      responseAt: responseAt ?? this.responseAt,
      message: message ?? this.message,
    );
  }
}
