import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String photoUrl;
  final bool isOnLine;
  final DateTime lastSeen;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl = "",
    this.isOnLine = false,
    required this.lastSeen,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "email": email,
      "displayName": displayName,
      "photoUrl": photoUrl,
      "isOnLine": isOnLine,
      "lastSeen": lastSeen,
      "createdAt": createdAt
    };
  }

  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(id: map["id"] ?? "",
        email: map["email"] ?? "",
        displayName: map["displayName"] ?? "",
        photoUrl: map["photoUrl"] ?? "",
        isOnLine: map["isOnLine"] ?? "",
        lastSeen: map["lastSeen"]!= null?(map['lastSeen']as Timestamp).toDate():DateTime.now(),
        createdAt: map["createdAt"]!= null?(map['createdAt']as Timestamp).toDate():DateTime.now()
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isOnLine,
    DateTime? lastSeen,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isOnLine: isOnLine ?? this.isOnLine,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
