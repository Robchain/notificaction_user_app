import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/user_viewmodel.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registrationState = ref.watch(userRegistrationViewModelProvider);
    final registrationViewModel = ref.read(userRegistrationViewModelProvider.notifier);

    // Escuchar cambios en el estado para mostrar mensajes
    ref.listen<RegistrationState>(userRegistrationViewModelProvider, (previous, next) {
      if (next.registeredUser != null) {
        // Usuario registrado exitosamente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Bienvenido ${next.registeredUser!.name}!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Limpiar formulario
        _usernameController.clear();
        _nameController.clear();
        
        // Limpiar el usuario registrado del estado después de mostrar el mensaje
        Future.delayed(const Duration(seconds: 1), () {
          registrationViewModel.clearRegisteredUser();
        });
      }

      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        registrationViewModel.clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Usuario'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            
            // Logo o icono
            const Icon(
              Icons.person_add,
              size: 80,
              color: Colors.blue,
            ),
            
            const SizedBox(height: 32),
            
            // Título
            Text(
              'Crear Nueva Cuenta',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Completa los campos para registrarte',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Formulario
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Campo de nombre de usuario
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de Usuario',
                      hintText: 'Ej: johndoe123',
                      prefixIcon: Icon(Icons.alternate_email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa un nombre de usuario';
                      }
                      if (value.trim().length < 3) {
                        return 'El nombre de usuario debe tener al menos 3 caracteres';
                      }
                      if (value.contains(' ')) {
                        return 'El nombre de usuario no puede contener espacios';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Campo de nombre
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre Completo',
                      hintText: 'Ej: John Doe',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa tu nombre completo';
                      }
                      if (value.trim().length < 2) {
                        return 'El nombre debe tener al menos 2 caracteres';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Botón de registro
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: registrationState.isLoading 
                        ? null 
                        : () => _handleRegistration(registrationViewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: registrationState.isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Registrando...'),
                            ],
                          )
                        : const Text(
                            'Registrar Usuario',
                            style: TextStyle(fontSize: 16),
                          ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Botón para ver usuarios registrados
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/users');
                    },
                    child: const Text('Ver Usuarios Registrados'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRegistration(UserRegistrationViewModel viewModel) {
    if (_formKey.currentState?.validate() ?? false) {
      viewModel.registerUser(
        username: _usernameController.text.trim(),
        name: _nameController.text.trim(),
      );
    }
  }
}