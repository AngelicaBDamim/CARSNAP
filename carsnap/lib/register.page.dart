import 'package:carsnap/home.page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key}); 

  @override
  RegisterPageState createState() =>
      RegisterPageState(); 
}

class RegisterPageState extends State<RegisterPage> {
  
  final _formKey = GlobalKey<FormState>();

  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  
  final _auth = FirebaseAuth.instance;

  
  bool _isLoading = false;

  
  Future<void> registrar(BuildContext context) async {
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; 
      });
      try {
        final name = _nameController.text.trim(); 
        final email = _emailController.text.trim(); 
        final password =
            _passwordController.text.trim(); 

        
        await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        
        await _auth.currentUser?.updateDisplayName(name);

        
        Navigator.pushReplacement(
            
            context,
            MaterialPageRoute(builder: (_) => HomePage()));
      } on FirebaseAuthException catch (e) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar usuário: ${e.message}'),
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
                        'assets/images/logo_carsnap.png'), // Caminho da imagem
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
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
                key:
                    _formKey, 
                child: Column(
                  children: [
                    
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: "Nome",
                        labelText: "Nome",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, informe o seu nome'; 
                        }
                        return null; 
                      },
                    ),
                    const SizedBox(height: 10),
                    
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType
                          .emailAddress, 
                      decoration: const InputDecoration(
                        hintText: "E-mail (obrigatório)",
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
                    const SizedBox(height: 20),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null 
                            : () => registrar(context),
                        child: _isLoading
                            ? const CircularProgressIndicator
                                .adaptive() 
                            : const Text("Cadastre-se"),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    TextButton(
                      child: const Text("Voltar"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
