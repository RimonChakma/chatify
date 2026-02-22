import 'package:chatify/controller/auth/auth_controller.dart';
import 'package:chatify/model/friend_request_model.dart';
import 'package:chatify/model/friendship_model.dart';
import 'package:chatify/model/user_model.dart';
import 'package:chatify/service/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

enum UserRelationshipStatus {
  none,
  friendRequestSent,
  friendRequestReceived,
  friends,
  blocked,
}

class UserListController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();
  final Uuid _uuid = Uuid();

  final RxList<UserModel> _user = <UserModel>[].obs;
  final RxList<UserModel> _filteredUsers = <UserModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = "".obs;
  final RxString _error = "".obs;

  final RxMap<String, UserRelationshipStatus> _userRelationships =
      <String, UserRelationshipStatus>{}.obs;
  final RxList<FriendRequestModel> _sentRequest = <FriendRequestModel>[].obs;
  final RxList<FriendRequestModel> _receivedRequest =
      <FriendRequestModel>[].obs;
  final RxList<FriendShipModel> _friendShip = <FriendShipModel>[].obs;

  List<UserModel> get users => _user;

  List<UserModel> get filteredUsers => _filteredUsers;

  bool get isLoading => _isLoading.value;

  String get searchQuery => _searchQuery.value;

  String get error => _error.value;

  Map<String, UserRelationshipStatus> get userRelationships =>
      _userRelationships;

  @override
  void onInit() {
    super.onInit();
    _loadUsers();
    _loadRelationships();

    debounce(
      _sentRequest,
      (_) => _filteredUsers(),
      time: Duration(milliseconds: 300),
    );
  }

  void _loadUsers() async {
    _user.bindStream(_firestoreService.getAllUserStream());

    ever(_user, List<UserModel> userList) {
      final currentUserId = _authController.user?.uid;
      final otherUsers = userList
          .where((user) => user.id != currentUserId)
          .toList();
      if (_searchQuery.isEmpty) {
        _filteredUsers.value = otherUsers;
      } else {
        _filteredUsers();
      }
    }
  }

  void _loadRelationships() {
    final currentUserId = _authController.user?.uid;

    if (currentUserId != null) {
      _sentRequest.bindStream(
        _firestoreService.getSentFriendRequestStream(currentUserId),
      );
      _receivedRequest.bindStream(
        _firestoreService.getFriendRequestStream(currentUserId),
      );
      _friendShip.bindStream(_firestoreService.getFriendStream(currentUserId));

      ever(_sentRequest, (_) => _updateAllRelationShipStatus());
      ever(_receivedRequest, (_) => _updateAllRelationShipStatus);
      ever(_friendShip, (_) => _updateAllRelationShipStatus());

      ever(_user, (_) => _updateAllRelationShipStatus());
    }
  }

  void _updateAllRelationShipStatus() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;
    for (var user in _user) {
      if (user.id != currentUserId) {
        final status = _calculateUserRelationshipStatus(user.id);
        _userRelationships[user.id] = status;
      }
    }
  }

  UserRelationshipStatus _calculateUserRelationshipStatus(String userId) {
    final currentUserId = _authController.user?.uid;

    if (currentUserId == null) {
      return UserRelationshipStatus.none;
    }

    final friendship = _friendShip.firstWhereOrNull(
      (f) =>
          (f.user1Id == currentUserId && f.user2Id == userId) ||
          (f.user1Id == userId && f.user2Id == currentUserId),
    );

    if (friendship != null) {
      if (friendship.isBlocked) {
        return UserRelationshipStatus.blocked;
      } else {
        return UserRelationshipStatus.friends;
      }
    }

    final sentRequest = _sentRequest.firstWhereOrNull(
      (r) => r.receivedId == userId && r.status == FriendRequestStatus.pending,
    );

    if (sentRequest != null) {
      return UserRelationshipStatus.friendRequestSent;
    }

    final receivedRequest = _receivedRequest.firstWhereOrNull(
      (r) => r.senderId == userId && r.status == FriendRequestStatus.pending,
    );

    if (receivedRequest != null) {
      return UserRelationshipStatus.friendRequestReceived;
    }

    return UserRelationshipStatus.none;
  }

  void _filterUsers() {
    final currentUserId = _authController.user?.uid;
    final query = _searchQuery.value.toLowerCase();

    if (currentUserId == null) return;

    if (query.isEmpty) {
      _filteredUsers.value = _user
          .where((user) => user.id != currentUserId)
          .toList();
    } else {
      _filteredUsers.value = _user.where((user) {
        return user.id != currentUserId &&
            (user.displayName.toLowerCase().contains(query) ||
                user.email.toLowerCase().contains(query));
      }).toList();
    }
  }

  void _updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void clearSearch() {
    _searchQuery.value = "";
  }

  Future<void> sentFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;
      if (currentUserId != null) {
        final request = FriendRequestModel(
          id: _uuid.v4(),
          senderId: currentUserId,
          receivedId: user.id,
          createdAt: DateTime.now(),
        );

        _userRelationships[user.id] = UserRelationshipStatus.friendRequestSent;
        await _firestoreService.sendFriendRequest(request);
        Get.snackbar("success", "Failed request sent to ${user.displayName}");
      }
      Get.snackbar("success", "Friend request sent to ${user.displayName}");
    } catch (e) {
      _userRelationships[user.id] = UserRelationshipStatus.none;
      _error.value = e.toString();
      Get.snackbar("Error", "Failed to send friend request");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> cancelFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;
      if (currentUserId != null) {
        final sentRequest = _sentRequest.firstWhereOrNull(
          (r) =>
              r.receivedId == user.id &&
              r.status == FriendRequestStatus.pending,
        );
        if(sentRequest !=null){
          await _firestoreService.cancelFriendRequest(sentRequest.id);
          _userRelationships[user.id] = UserRelationshipStatus.none;
          Get.snackbar("success", "Friend request cancelled");
        }
      }
    } catch (e) {
      _userRelationships[user.id] = UserRelationshipStatus.friendRequestSent;
      _error.value = e.toString();
      Get.snackbar("Error", "Failed to cancel friend request");
    } finally {
      _isLoading.value = false;
    }
  }
}
