import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:money_tracker/data/repositories/repository.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit({required this.repository})
      : super(AuthenticateInitial());
  final Repository repository;

  Future<void> authenticateWithBiometrics() async {
    emit(Authenticating());
    if (repository.isEnableFingerprint()) {
      try {
        final _auth = LocalAuthentication();
        final authenticated = await _auth.authenticate(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        );
        emit(authenticated ? Authenticated() : const Unauthenticated());
      } on PlatformException catch (e) {
        emit(Unauthenticated(message: e.message!));
      }
    } else {
      emit(Authenticated());
    }
  }
}
