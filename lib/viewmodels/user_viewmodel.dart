import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';
import '../services/notification_service.dart';

// Estado del formulario de registro
class RegistrationState {
  final bool isLoading;
  final String? error;
  final User? registeredUser;

  const RegistrationState({
    this.isLoading = false,
    this.error,
    this.registeredUser,
  });

  RegistrationState copyWith({
    bool? isLoading,
    String? error,
    User? registeredUser,
  }) {
    return RegistrationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      registeredUser: registeredUser ?? this.registeredUser,
    );
  }
}

// Provider para el repositorio
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl();
});

// Provider para el servicio de notificaciones
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// ViewModel para el registro de usuarios
class UserRegistrationViewModel extends StateNotifier<RegistrationState> {
  final UserRepository _userRepository;
  final NotificationService _notificationService;

  UserRegistrationViewModel({
    required UserRepository userRepository,
    required NotificationService notificationService,
  }) : _userRepository = userRepository,
       _notificationService = notificationService,
       super(const RegistrationState());

  Future<void> registerUser({
    required String username,
    required String name,
  }) async {
    if (username.trim().isEmpty || name.trim().isEmpty) {
      state = state.copyWith(
        error: 'Por favor completa todos los campos',
        isLoading: false,
      );
      return;
    }

    if (username.length < 3) {
      state = state.copyWith(
        error: 'El nombre de usuario debe tener al menos 3 caracteres',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _userRepository.registerUser(username, name);
      
      // Mostrar notificación
      await _notificationService.showUserRegisteredNotification(
        username: user.username,
        name: user.name,
      );

      state = state.copyWith(
        isLoading: false,
        registeredUser: user,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearRegisteredUser() {
    state = state.copyWith(registeredUser: null);
  }
}

// Provider para el ViewModel
final userRegistrationViewModelProvider =
    StateNotifierProvider<UserRegistrationViewModel, RegistrationState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  
  return UserRegistrationViewModel(
    userRepository: userRepository,
    notificationService: notificationService,
  );
});

// Provider para obtener la lista de usuarios
final usersListProvider = FutureProvider<List<User>>((ref) async {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUsers();
});