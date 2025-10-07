import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled2/delete/screens/user/user_main_screen.dart';
import 'package:untitled2/features/4_driver_panel/presentation/screens/bus_selection_screen.dart';
import 'package:untitled2/features/2_map_view/presentation/screens/user_map_screen.dart';
import 'package:untitled2/services/auth_service.dart';
import '../../features/1_auth/data/models/user_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  UserModel? _userModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      User? user = await _authService.user.first;
      if (user != null) {
        UserModel? userModel = await _authService.getUserDetails(user.uid);
        if (userModel != null) {
          setState(() {
            _userModel = userModel;
            _isLoading = false;
          });
        } else {
          // Si no se pudo obtener el UserModel, cerrar sesión
          await _authService.signOut();
          Navigator.pushReplacementNamed(context, '/');
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading user details: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Pantalla Principal'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _userModel == null
          ? const Center(child: Text('No se pudo cargar los detalles del usuario.'))
          : _userModel!.role == 'Conductor'
          ? DriverScreen() // Pantalla para conductores
          :UserMainScreen(),
      //     : UserMapScreen(), // Pantalla para usuarios
    );
  }
}
