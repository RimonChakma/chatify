class ChatModel {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;
  final Map<String, bool> deleteBy;
  final Map<String, DateTime?> deleteAt;
  final Map<String, DateTime?> lastSeenBy;
  final DateTime createAt;
  final DateTime updateAt;

  ChatModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    required this.unreadCount,
    this.deleteBy = const {},
    this.deleteAt = const {},
    this.lastSeenBy = const {},
    required this.createAt,
    required this.updateAt,
  });

  // Convert ChatModel -> Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.millisecondsSinceEpoch,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'deleteBy': deleteBy,
      'deleteAt': deleteAt.map(
            (key, value) => MapEntry(key, value?.millisecondsSinceEpoch),
      ),
      'lastSeenBy': lastSeenBy.map(
            (key, value) => MapEntry(key, value?.millisecondsSinceEpoch),
      ),
      'createAt': createAt.millisecondsSinceEpoch,
      'updateAt': updateAt.millisecondsSinceEpoch,
    };
  }

  // Convert Map -> ChatModel
  static ChatModel fromMap(Map<String, dynamic> map) {
    Map<String, DateTime?> lastSeenMap = {};
    if (map["lastSeenBy"] != null) {
      final rawLastSeen = Map<String, dynamic>.from(map["lastSeenBy"]);
      lastSeenMap = rawLastSeen.map(
            (key, value) => MapEntry(
          key,
          value != null ? DateTime.fromMillisecondsSinceEpoch(value as int) : null,
        ),
      );
    }

    Map<String, DateTime?> deleteAtMap = {};
    if (map["deleteAt"] != null) {
      final rawDeleteAt = Map<String, dynamic>.from(map["deleteAt"]);
      deleteAtMap = rawDeleteAt.map(
            (key, value) => MapEntry(
          key,
          value != null ? DateTime.fromMillisecondsSinceEpoch(value as int) : null,
        ),
      );
    }

    return ChatModel(
      id: map["id"],
      participants: List<String>.from(map["participants"]),
      lastMessage: map["lastMessage"],
      lastMessageTime: map["lastMessageTime"] != null
          ? DateTime.fromMillisecondsSinceEpoch(map["lastMessageTime"] as int)
          : null,
      lastMessageSenderId: map["lastMessageSenderId"],
      unreadCount: Map<String, int>.from(map["unreadCount"]),
      deleteBy: Map<String, bool>.from(map["deleteBy"] ?? {}),
      deleteAt: deleteAtMap,
      lastSeenBy: lastSeenMap,
      createAt: DateTime.fromMillisecondsSinceEpoch(map["createAt"] as int),
      updateAt: DateTime.fromMillisecondsSinceEpoch(map["updateAt"] as int),
    );
  }

  // copyWith
  ChatModel copyWith({
    String? id,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    Map<String, int>? unreadCount,
    Map<String, bool>? deleteBy,
    Map<String, DateTime?>? deleteAt,
    Map<String, DateTime?>? lastSeenBy,
    DateTime? createAt,
    DateTime? updateAt,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      deleteBy: deleteBy ?? this.deleteBy,
      deleteAt: deleteAt ?? this.deleteAt,
      lastSeenBy: lastSeenBy ?? this.lastSeenBy,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
    );
  }

  // get other participant id
  String? getOtherParticipantId(String currentUserId) {
    try {
      return participants.firstWhere((id) => id != currentUserId);
    } catch (e) {
      return null;
    }
  }

  // get unread count for current user
  int getUnreadCount(String currentUserId) {
    return unreadCount[currentUserId] ?? 0;
  }

  // check if chat is deleted for current user
  bool isDeleteBy(String currentUserId) {
    return deleteBy[currentUserId] ?? false;
  }

  // get deleteAt time for current user
  DateTime? getDeleteAt(String currentUserId) {
    return deleteAt[currentUserId];
  }

  // get lastSeenBy time for current user
  DateTime? getLastSeenBy(String currentUserId) {
    return lastSeenBy[currentUserId];
  }

  // check if last message seen by current user against other user
  bool isMessageSeen(String currentUserId, String otherUserId) {
    final DateTime? currentUserSeen = lastSeenBy[currentUserId];
    final DateTime? otherUserMessageTime =
    lastMessageSenderId == otherUserId ? lastMessageTime : null;

    if (currentUserSeen == null || otherUserMessageTime == null) {
      return false;
    }

    return currentUserSeen.isAfter(otherUserMessageTime) ||
        currentUserSeen.isAtSameMomentAs(otherUserMessageTime);
  }
}
