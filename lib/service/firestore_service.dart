import 'package:chatify/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser (UserModel user) async {
    try{
      await _firestore.collection("users").doc(user.id).set(user.toMap());
    }catch(e){
      throw Exception('Failed TO created User :${e.toString()}');
    }
  }
  Future<UserModel?> getUser (String userId) async {
    try{
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if(doc.exists){
        return UserModel.fromMap(doc.data() as Map<String,dynamic>);
      }
      return null;
    }catch (e){
      throw Exception('Failed To Get User :${e.toString()}');
    }
  }

  Future<void> updateUserOnLineStatus (String userId,bool isOnLine) async {
    try{
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if(doc.exists){
        await _firestore.collection('users').doc(userId).update(
            {'isOnLine': isOnLine, 'lastSeen': DateTime
                .now()
                .millisecondsSinceEpoch});
      }
    }catch(e){
      throw Exception('Failed to update user Online status :${e.toString()}');
    }
  }

  Future<void> deleteUser (String userId)async {
    try{
      await _firestore.collection('users').doc(userId).delete();

    }catch (e){
      throw Exception('Failed to delete user :${e.toString()}');
    }
  }
}