import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Authentication methods
  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  static Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await credential.user?.updateDisplayName(displayName);
      
      // Create user document in Firestore
      await _createUserDocument(credential.user!);
      
      return credential;
    } catch (e) {
      print('Sign up error: $e');
      return null;
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Create user document in Firestore
  static Future<void> _createUserDocument(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'preferences': {
          'theme': 'system',
          'notifications': true,
          'currency': 'USD',
        },
      });
    } catch (e) {
      print('Error creating user document: $e');
    }
  }

  // Update user document
  static Future<void> updateUserDocument(Map<String, dynamic> data) async {
    if (currentUser == null) return;
    
    try {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user document: $e');
    }
  }

  // Get user document
  static Future<DocumentSnapshot?> getUserDocument() async {
    if (currentUser == null) return null;
    
    try {
      return await _firestore.collection('users').doc(currentUser!.uid).get();
    } catch (e) {
      print('Error getting user document: $e');
      return null;
    }
  }

  // Firestore methods for transactions
  static Future<void> addTransaction(Map<String, dynamic> transactionData) async {
    if (currentUser == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('transactions')
          .add({
        ...transactionData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding transaction: $e');
    }
  }

  // Get transactions stream
  static Stream<QuerySnapshot> getTransactionsStream() {
    if (currentUser == null) {
      return const Stream.empty();
    }
    
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Firestore methods for budgets
  static Future<void> addBudget(Map<String, dynamic> budgetData) async {
    if (currentUser == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('budgets')
          .add({
        ...budgetData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding budget: $e');
    }
  }

  // Get budgets stream
  static Stream<QuerySnapshot> getBudgetsStream() {
    if (currentUser == null) {
      return const Stream.empty();
    }
    
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('budgets')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Firestore methods for goals
  static Future<void> addGoal(Map<String, dynamic> goalData) async {
    if (currentUser == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('goals')
          .add({
        ...goalData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding goal: $e');
    }
  }

  // Get goals stream
  static Stream<QuerySnapshot> getGoalsStream() {
    if (currentUser == null) {
      return const Stream.empty();
    }
    
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('goals')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Firebase Messaging methods
  static Future<String?> getFCMToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Request notification permissions
  static Future<bool> requestNotificationPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      print('Error requesting notification permissions: $e');
      return false;
    }
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  // Initialize Firebase Messaging
  static Future<void> initializeMessaging() async {
    try {
      // Request permissions
      await requestNotificationPermissions();
      
      // Get FCM token
      final token = await getFCMToken();
      print('FCM Token: $token');
      
      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
        
        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');
        }
      });
      
      // Handle notification taps
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('A new onMessageOpenedApp event was published!');
        print('Message data: ${message.data}');
      });
      
    } catch (e) {
      print('Error initializing Firebase Messaging: $e');
    }
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}














