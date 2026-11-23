import 'package:cadence_tasks/core/domain/failure.dart';
import 'package:cadence_tasks/core/domain/result.dart';
import 'package:cadence_tasks/data/local/drift/drift_sync_repository.dart';
import 'package:cadence_tasks/features/authentication/domain/auth_user.dart';
import 'package:cadence_tasks/features/authentication/domain/authentication_repository.dart';
import 'package:cadence_tasks/infrastructure/firebase/firebase_runtime_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

final class FirebaseAuthenticationRepository
    implements AuthenticationRepository {
  FirebaseAuthenticationRepository({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required DriftSyncRepository localSyncRepository,
    required FirebaseRuntimeConfig config,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       _localSyncRepository = localSyncRepository,
       _config = config,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  static const _userCollections = [
    'routineTemplates',
    'routineOccurrenceLogs',
    'oneOffTasks',
    'calendarPreferences',
  ];

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final DriftSyncRepository _localSyncRepository;
  final FirebaseRuntimeConfig _config;
  final GoogleSignIn _googleSignIn;
  bool _googleInitialized = false;

  @override
  Stream<AuthUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_toDomain);
  }

  @override
  Future<Result<AuthUser>> signInWithGoogle() async {
    try {
      final firebase_auth.UserCredential credential;
      if (kIsWeb) {
        credential = await _firebaseAuth.signInWithPopup(
          firebase_auth.GoogleAuthProvider(),
        );
      } else {
        if (_config.googleServerClientId.isEmpty) {
          return const FailureResult<AuthUser>(
            ValidationFailure(
              'Google sign-in requires a server client ID in Firebase setup.',
            ),
          );
        }
        if (!_googleInitialized) {
          await _googleSignIn.initialize(
            serverClientId: _config.googleServerClientId,
          );
          _googleInitialized = true;
        }

        final account = await _googleSignIn.authenticate();
        final idToken = account.authentication.idToken;
        if (idToken == null || idToken.isEmpty) {
          return const FailureResult<AuthUser>(
            UnavailableFailure('Google sign-in did not return an ID token.'),
          );
        }
        credential = await _firebaseAuth.signInWithCredential(
          firebase_auth.GoogleAuthProvider.credential(idToken: idToken),
        );
      }

      final user = credential.user;
      if (user == null) {
        return const FailureResult<AuthUser>(
          UnavailableFailure('Google sign-in returned no authenticated user.'),
        );
      }
      return Success<AuthUser>(_mapUser(user));
    } on firebase_auth.FirebaseAuthException catch (error) {
      return FailureResult<AuthUser>(
        UnavailableFailure(
          error.message ?? 'Google sign-in failed (${error.code}).',
        ),
      );
    } on GoogleSignInException catch (error) {
      return FailureResult<AuthUser>(
        UnavailableFailure(
          error.description ?? 'Google sign-in was not completed.',
        ),
      );
    } on PlatformException catch (error) {
      return FailureResult<AuthUser>(
        UnavailableFailure(
          error.message ?? 'Google sign-in is unavailable on this device.',
        ),
      );
    }
  }

  @override
  Future<Result<Unit>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      return const Success<Unit>(Unit.value);
    } on firebase_auth.FirebaseAuthException catch (error) {
      return FailureResult<Unit>(
        UnavailableFailure(error.message ?? 'Sign-out failed (${error.code}).'),
      );
    } on GoogleSignInException catch (error) {
      return FailureResult<Unit>(
        UnavailableFailure(error.description ?? 'Google sign-out failed.'),
      );
    } on PlatformException catch (error) {
      return FailureResult<Unit>(
        UnavailableFailure(error.message ?? 'Google sign-out failed.'),
      );
    }
  }

  @override
  Future<Result<Unit>> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return const FailureResult<Unit>(
        ValidationFailure('There is no signed-in account to delete.'),
      );
    }

    try {
      final reauthentication = await _reauthenticate(user);
      if (reauthentication case FailureResult<Unit>()) {
        return reauthentication;
      }

      for (final collectionName in _userCollections) {
        await _deleteCloudCollection(user.uid, collectionName);
      }
      await _localSyncRepository.deleteUserData(user.uid);
      await user.delete();
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      return const Success<Unit>(Unit.value);
    } on firebase_auth.FirebaseAuthException catch (error) {
      return FailureResult<Unit>(
        UnavailableFailure(
          error.message ?? 'Account deletion failed (${error.code}).',
        ),
      );
    } on FirebaseException catch (error) {
      return FailureResult<Unit>(
        UnavailableFailure(
          error.message ?? 'Account data deletion failed (${error.code}).',
        ),
      );
    } on GoogleSignInException catch (error) {
      return FailureResult<Unit>(
        UnavailableFailure(
          error.description ?? 'Google reauthentication was not completed.',
        ),
      );
    } on PlatformException catch (error) {
      return FailureResult<Unit>(
        UnavailableFailure(
          error.message ?? 'Account deletion is unavailable on this device.',
        ),
      );
    }
  }

  Future<Result<Unit>> _reauthenticate(firebase_auth.User user) async {
    if (kIsWeb) {
      await user.reauthenticateWithPopup(firebase_auth.GoogleAuthProvider());
      return const Success<Unit>(Unit.value);
    }
    if (_config.googleServerClientId.isEmpty) {
      return const FailureResult<Unit>(
        ValidationFailure(
          'Account deletion requires a configured Google server client ID.',
        ),
      );
    }
    if (!_googleInitialized) {
      await _googleSignIn.initialize(
        serverClientId: _config.googleServerClientId,
      );
      _googleInitialized = true;
    }

    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      return const FailureResult<Unit>(
        UnavailableFailure('Google sign-in did not return an ID token.'),
      );
    }

    await user.reauthenticateWithCredential(
      firebase_auth.GoogleAuthProvider.credential(idToken: idToken),
    );
    return const Success<Unit>(Unit.value);
  }

  Future<void> _deleteCloudCollection(
    String userId,
    String collectionName,
  ) async {
    final collection = _firestore
        .collection('users')
        .doc(userId)
        .collection(collectionName);
    while (true) {
      final snapshot = await collection
          .limit(400)
          .get(const GetOptions(source: Source.server));
      if (snapshot.docs.isEmpty) {
        return;
      }

      final batch = _firestore.batch();
      for (final document in snapshot.docs) {
        batch.delete(document.reference);
      }
      await batch.commit();
    }
  }

  static AuthUser? _toDomain(firebase_auth.User? user) {
    return user == null ? null : _mapUser(user);
  }

  static AuthUser _mapUser(firebase_auth.User user) {
    return AuthUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }
}
