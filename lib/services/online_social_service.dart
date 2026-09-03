import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

/// Secure client-side gateway for the online social features.
/// Firestore/Storage security rules remain the authority; this class never
/// contains admin credentials or server secrets.
class OnlineSocialService {
  OnlineSocialService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signInAnonymously() => _auth.signInAnonymously();

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> reloadCurrentUser() async {
    await _auth.currentUser?.reload();
  }

  Future<void> updateDisplayName(String displayName) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not signed in');
    final name = displayName.trim();
    if (name.isEmpty) throw ArgumentError('Display name cannot be empty');
    await user.updateDisplayName(name);
    await upsertProfile(uid: user.uid, displayName: name);
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.isAnonymous && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  bool get isSignedIn => _auth.currentUser != null;

  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? false;

  String? get email => _auth.currentUser?.email;

  Future<UserCredential> registerOrLinkEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = EmailAuthProvider.credential(
      email: email.trim(),
      password: password,
    );
    final current = _auth.currentUser;
    UserCredential result;
    if (current != null && current.isAnonymous) {
      result = await current.linkWithCredential(credential);
    } else {
      result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    }
    final user = result.user;
    if (user != null && displayName != null && displayName.trim().isNotEmpty) {
      await user.updateDisplayName(displayName.trim());
    }
    if (user != null) {
      await upsertProfile(
        uid: user.uid,
        displayName: user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : 'Billi User',
      );
    }
    return result;
  }

  Future<UserCredential> signInEmailPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> upsertProfile({
    required String uid,
    required String displayName,
    String? photoUrl,
    String? country,
    String? language,
  }) {
    return _db.collection('users').doc(uid).set({
      'displayName': displayName.trim(),
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (country != null) 'country': country,
      if (language != null) 'language': language,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> follow(String targetUid) async {
    final uid = _requireUid();
    if (uid == targetUid) return;
    final batch = _db.batch();
    final followingRef = _db.collection('users').doc(uid).collection('following').doc(targetUid);
    final followerRef = _db.collection('users').doc(targetUid).collection('followers').doc(uid);
    batch.set(followingRef, {'createdAt': FieldValue.serverTimestamp()});
    batch.set(followerRef, {'createdAt': FieldValue.serverTimestamp()});
    await batch.commit();
  }

  Future<void> unfollow(String targetUid) async {
    final uid = _requireUid();
    final batch = _db.batch();
    batch.delete(_db.collection('users').doc(uid).collection('following').doc(targetUid));
    batch.delete(_db.collection('users').doc(targetUid).collection('followers').doc(uid));
    await batch.commit();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> usersStream() {
    return _db.collection('users').orderBy('displayName').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> followingStream() {
    final uid = _requireUid();
    return _db.collection('users').doc(uid).collection('following').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> followersStream(String uid) {
    return _db.collection('users').doc(uid).collection('followers').snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> userProfileStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(String otherUid) {
    final uid = _requireUid();
    final chatId = _chatId(uid, otherUid);
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots();
  }


  Future<void> registerPushToken({FirebaseMessaging? messaging}) async {
    final uid = _requireUid();
    final fcm = messaging ?? FirebaseMessaging.instance;
    final token = await fcm.getToken();
    if (token == null || token.isEmpty) return;
    await _db.collection('users').doc(uid).collection('deviceTokens').doc(token).set({
      'token': token,
      'platform': 'android',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removePushToken(String token) async {
    final uid = _requireUid();
    if (token.trim().isEmpty) return;
    await _db.collection('users').doc(uid).collection('deviceTokens').doc(token.trim()).delete();
  }

  Future<String> uploadPost({
    required String localPath,
    required String mediaType,
    String caption = '',
  }) async {
    final uid = _requireUid();
    final file = File(localPath);
    if (!await file.exists()) throw StateError('Media file not found.');
    final postId = _db.collection('posts').doc().id;
    final extension = localPath.contains('.')
        ? localPath.split('.').last.toLowerCase()
        : (mediaType == 'video' ? 'mp4' : 'jpg');
    final contentType = mediaType == 'video' ? 'video/mp4' : 'image/jpeg';
    final ref = FirebaseStorage.instance
        .ref()
        .child('users/$uid/posts/$postId.$extension');
    final metadata = SettableMetadata(contentType: contentType);
    await ref.putFile(file, metadata);
    final url = await ref.getDownloadURL();
    await _db.collection('posts').doc(postId).set({
      'ownerUid': uid,
      'mediaType': mediaType,
      'mediaUrl': url,
      'storagePath': ref.fullPath,
      'caption': caption.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return postId;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> postsStream() {
    if (!isSignedIn) return const Stream.empty();
    return _db.collection('posts').orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> deletePost(String postId, String? storagePath) async {
    final uid = _requireUid();
    final doc = await _db.collection('posts').doc(postId).get();
    if (!doc.exists || doc.data()?['ownerUid'] != uid) return;
    await _db.collection('posts').doc(postId).delete();
    if (storagePath != null && storagePath.isNotEmpty) {
      try {
        await FirebaseStorage.instance.ref(storagePath).delete();
      } catch (_) {}
    }
  }


  Future<void> likePost(String postId) async {
    final uid = _requireUid();
    final ref = _db.collection('posts').doc(postId).collection('likes').doc(uid);
    await ref.set({'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> unlikePost(String postId) async {
    final uid = _requireUid();
    await _db.collection('posts').doc(postId).collection('likes').doc(uid).delete();
  }

  Stream<bool> postLikedStream(String postId) {
    if (!isSignedIn) return Stream.value(false);
    final uid = _auth.currentUser!.uid;
    return _db.collection('posts').doc(postId).collection('likes').doc(uid).snapshots().map((d) => d.exists);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> commentsStream(String postId) {
    return _db.collection('posts').doc(postId).collection('comments').orderBy('createdAt').snapshots();
  }

  Future<void> addOnlineComment(String postId, String text) async {
    final uid = _requireUid();
    final clean = text.trim();
    if (clean.isEmpty || clean.length > 1000) return;
    await _db.collection('posts').doc(postId).collection('comments').add({
      'ownerUid': uid,
      'text': clean,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> notificationsStream() {
    if (!isSignedIn) return const Stream.empty();
    return _db.collection('users').doc(_auth.currentUser!.uid).collection('notifications').orderBy('createdAt', descending: true).limit(50).snapshots();
  }

  Future<void> markNotificationRead(String notificationId) async {
    final uid = _requireUid();
    await _db.collection('users').doc(uid).collection('notifications').doc(notificationId).update({
      'read': true,
    });
  }

  Future<void> markAllNotificationsRead(Iterable<String> notificationIds) async {
    final uid = _requireUid();
    final batch = _db.batch();
    for (final id in notificationIds) {
      batch.update(_db.collection('users').doc(uid).collection('notifications').doc(id), {'read': true});
    }
    await batch.commit();
  }

  Future<void> sendMessage({required String otherUid, required String text}) async {
    final uid = _requireUid();
    final clean = text.trim();
    if (clean.isEmpty) return;
    final chatId = _chatId(uid, otherUid);
    // Create/update the parent chat first so the message rule can verify
    // that the authenticated user is a chat member.
    await _db.collection('chats').doc(chatId).set({
      'members': [uid, otherUid],
      'lastMessage': clean,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _db.collection('chats').doc(chatId).collection('messages').add({
      'senderId': uid,
      'receiverId': otherUid,
      'text': clean,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('A signed-in Billi Billi user is required.');
    }
    return uid;
  }

  String _chatId(String a, String b) => a.compareTo(b) < 0 ? '${a}_$b' : '${b}_$a';
}
