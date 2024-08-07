

import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'welcome_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Ajout de l'image ronde en haut de la page
                  ClipOval(
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      height: 150, // Ajustez la hauteur selon vos besoins
                      width: 150,  // La largeur doit être égale à la hauteur pour obtenir un cercle
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Connexion',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                          SizedBox(height: 20),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.email),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Veuillez entrer votre email';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'Mot de passe',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.lock),
                                  ),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Veuillez entrer votre mot de passe';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _login,
                                  child: Text('Connexion'),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => RegisterPage()),
                                    );
                                  },
                                  child: Text(
                                    'Vous n\'avez pas de compte ? Inscrivez-vous',
                                    style: TextStyle(
                                      color: Colors.blueGrey[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userString = prefs.getString('user');

      if (userString != null) {
        try {
          Map<String, dynamic> userMap = jsonDecode(userString);  // Décode la chaîne JSON en Map
          User user = User.fromMap(userMap);  // Crée un objet User à partir du Map

          if (user.email == email && user.password == password) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Connexion réussie !')),
            );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => WelcomePage()),
              (Route<dynamic> route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Email ou mot de passe invalide')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la connexion : $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Utilisateur non trouvé')),
        );
      }
    }
  }
}
