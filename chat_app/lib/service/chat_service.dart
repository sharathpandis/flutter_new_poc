import 'package:chat_app/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Future<void> sendMessage(String recieverId, message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
    // const String currentUserId1 = "GScEQKmlNugWqo2er1Hw5jAJ6Cg2";
    // const String currentUserId2 = "7fAe351ztNRjMz5fIDmBMq5vwga2";
    // const String currentUserEmail1 = "sharath@gmail.com";
    // const String currentUserEmail2 = "test@gmail.com";
    // print("current email $currentUserEmail");
    // print("current Id $currentUserId");
    // print("recieverId $recieverId");
    // for (var i = 500; i > 0; i--) {
    //   List<String> ids = [];
    //   Message newMessage;
    //   if (i % 2 == 0) {
    //     print("hi $i");
    //     final Timestamp timestamp = Timestamp.now();
    //     newMessage = Message(
    //       senderId: currentUserId2,
    //       senderEmail: currentUserEmail2,
    //       recieverId: currentUserId1,
    //       message: "Hi $i",
    //       timestamp: timestamp,
    //     );
    //     ids = [currentUserId2, currentUserId1];
    //     ids.sort();
    //     String chatRoomId = ids.join('_');
    //     await _firestore
    //         .collection("chat_rooms")
    //         .doc(chatRoomId)
    //         .collection("messages")
    //         .add(newMessage.toMap());
    //   } else {
    //     print("hello $i");
    //     final Timestamp timestamp = Timestamp.now();
    //     newMessage = Message(
    //       senderId: currentUserId1,
    //       senderEmail: currentUserEmail1,
    //       recieverId: currentUserId2,
    //       message: "Hello $i",
    //       timestamp: timestamp,
    //     );
    //     ids = [currentUserId1, currentUserId2];
    //     ids.sort();
    //     String chatRoomId = ids.join('_');
    //     await _firestore
    //         .collection("chat_rooms")
    //         .doc(chatRoomId)
    //         .collection("messages")
    //         .add(newMessage.toMap());
    //   }
    //   ids.sort();
    //   String chatRoomId = ids.join('_');
    //   await _firestore
    //       .collection("chat_rooms")
    //       .doc(chatRoomId)
    //       .collection("messages")
    //       .add(newMessage.toMap());
    // }
    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      recieverId: recieverId,
      message: message,
      timestamp: timestamp,
    );
    List<String> ids = [currentUserId, recieverId];
    ids.sort();
    String chatRoomId = ids.join('_');
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(
      String userId, senderId, int msgCount, DocumentSnapshot? lastDocument) {
    List<String> ids = [userId, senderId];
    ids.sort();
    String chatRoomId = ids.join('_');
    // getDocumentSnapshots(userId, senderId, typing);
    Query<Map<String, dynamic>> messages;

    if (lastDocument == null) {
      messages = _getNewMessages(chatRoomId);
      return messages.snapshots();
    } else {
      messages = _getOlderMessages(chatRoomId, lastDocument);
      return messages.snapshots();
    }
    // return _firestore
    //     .collection("chat_rooms")
    //     .doc(chatRoomId)
    //     .collection("messages")
    //     .orderBy("timestamp", descending: false)
    //     .limitToLast(msgCount)
    //     .snapshots();
  }

  Query<Map<String, dynamic>> _getNewMessages(String chatRoomId) {
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(20);
  }

  Query<Map<String, dynamic>> _getOlderMessages(
      String chatRoomId, DocumentSnapshot? lastDocument) {
    print("fetchold $lastDocument");
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy('timestamp', descending: true)
        .startAfterDocument(lastDocument!)
        .limit(20);
  }
  // Future<Map<String, dynamic>> getDocumentSnapshots(
  //   String userId,
  //   senderId,
  //   bool typing,
  // ) async {
  //   List<String> ids = [userId, senderId];
  //   ids.sort();
  //   String chatRoomId = ids.join('_');
  //   DocumentSnapshot documentSnapshots =
  //       await _firestore.collection("chat_rooms").doc(chatRoomId).get();
  //   if (documentSnapshots.exists) {
  //     Map<String, dynamic> data =
  //         documentSnapshots.data() as Map<String, dynamic>;

  //     // Get the field names
  //     // List<String> fieldNames = data.keys.toList();
  //     // for (String fieldName in fieldNames) {
  //     //   if (fieldName == "typing") {
  //     //     data[fieldName] = typing;
  //     //     print('$fieldName: ${data[fieldName]}');
  //     //   }
  //     // }

  //     // await _firestore.collection("chat_rooms").doc(chatRoomId).update(data);
  //     // Print the field names
  //   }
  // }
}
