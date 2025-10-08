import 'dart:async';
import 'package:ica_app/src/screens/login/auth/auth_event.dart';
import 'package:ica_app/src/screens/login/auth/auth_state.dart';

class AuthBloc {
  final _stateController = StreamController<AuthState>.broadcast();
  Stream<AuthState> get state => _stateController.stream;

  AuthState _currentState = AuthInitial();
  AuthState get currentState => _currentState;

  final _eventController = StreamController<AuthEvent>();
  Sink<AuthEvent> get eventSink => _eventController.sink;

  AuthBloc() {
    _eventController.stream.listen(_mapEventToState);
  }

  void _mapEventToState(AuthEvent event) async {
    if (event is LoginRequested) {
      _updateState(AuthLoading());

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Simple validation
      if (event.email.isNotEmpty && event.password.isNotEmpty) {
        _updateState(AuthSuccess(event.email));
      } else {
        _updateState(AuthFailure('Invalid email or password'));
      }
    } else if (event is LogoutRequested) {
      _updateState(AuthInitial());
    }
  }

  void _updateState(AuthState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  void dispose() {
    _stateController.close();
    _eventController.close();
  }
}

// Navigation BLoC for Bottom Nav
class NavigationBloc {
  final _indexController = StreamController<int>.broadcast();
  Stream<int> get indexStream => _indexController.stream;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void changeTab(int index) {
    _currentIndex = index;
    _indexController.add(index);
  }

  void dispose() {
    _indexController.close();
  }
}