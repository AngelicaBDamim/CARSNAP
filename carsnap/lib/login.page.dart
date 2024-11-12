import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carsnap/home.page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() =>
      LoginPageState(); 
}

class LoginPageState extends State<LoginPage> {
  
  final _formKey = GlobalKey<FormState>();

  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  
  final _auth = FirebaseAuth.instance;

  
  bool _isLoading = false;

  Future<void> login(BuildContext context) async {
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; 
      });
      try {
        final email = _emailController.text.trim(); 
        final password =
            _passwordController.text.trim(); 

        
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);

        
        Navigator.of(context).pushReplacementNamed('/home');
      } on FirebaseAuthException catch (e) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer login: ${e.message}'),
          ),
        );
      } finally {
        
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    if (_auth.currentUser != null) {
      
      return HomePage(); 
    } else {
      
      return Scaffold(
        body: Container(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              Container(
                height: 300,
                width: 300,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/logo_carsnap.png'), 
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Nome do App
              const Text(
                'CarSnap', 
                style: TextStyle(
                  fontSize: 36, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.blueAccent, 
                ),
              ),
              const SizedBox(height: 20),
              
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: "E-mail (required)",
                        labelText: "E-mail",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, informe o seu e-mail';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        hintText: "Password",
                        labelText: "Senha",
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, informe a sua senha';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Botão de login
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null 
                      : () => login(context),
                  child: _isLoading
                      ? const CircularProgressIndicator() 
                      : const Text("Login"),
                ),
              ),
              const SizedBox(height: 10),
              
              TextButton(
                onPressed: _isLoading
                    ? null 
                    : () {
                        Navigator.pushNamed(context, '/register');
                      },
                child: _isLoading
                    ? const CircularProgressIndicator
                        .adaptive() 
                    : const Text("Novo usuário? Cadastre-se aqui"),
              ),
            ],
          ),
        ),
      );
    }
  }
}
