import '../models/user.dart';

abstract class UserRepository {
  Future<User> registerUser(String username, String name);
  Future<List<User>> getUsers();
  Future<User?> getUserByUsername(String username);
}

class UserRepositoryImpl implements UserRepository {
  final List<User> _users = [];

  @override
  Future<User> registerUser(String username, String name) async {
    // Simular delay de red
    await Future.delayed(const Duration(seconds: 1));

    // Verificar si el usuario ya existe
    if (_users.any((user) => user.username.toLowerCase() == username.toLowerCase())) {
      throw Exception('El nombre de usuario ya existe');
    }

    final newUser = User(
      username: username.trim(),
      name: name.trim(),
      createdAt: DateTime.now(),
    );

    _users.add(newUser);
    return newUser;
  }

  @override
  Future<List<User>> getUsers() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_users);
  }

  @override
  Future<User?> getUserByUsername(String username) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      return _users.firstWhere(
        (user) => user.username.toLowerCase() == username.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}