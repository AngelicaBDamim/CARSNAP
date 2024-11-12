import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class Car {
  final String marca;
  final String modelo;
  final int ano;
  final String cor;

  Car(
      {required this.marca,
      required this.modelo,
      required this.ano,
      required this.cor});

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      marca: json['marca'],
      modelo: json['modelo'],
      ano: json['ano'],
      cor: json['cor'],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? _imageBytes; 
  
  bool _isLoading = false; 
  String? _result;
  String errorText = ""; 
  final _auth = FirebaseAuth.instance; 
  final gemini = Gemini.instance; 

  late Car car;
  // Função que processa a imagem e envia para a API do Gemini
  Future<void> _processImage() async {
    if (_imageBytes == null) return;

    setState(() {
      _isLoading = true; 
      _result = null; 
      errorText = ""; 
    });

    try {
      
      final result = await gemini.textAndImage(
        text:
            'Crie um JSON em português brasileiro descrevendo um carro. Inclua as informações: marca, modelo, ano e cor.', 
        images: [_imageBytes!], 
      );

      setState(() {
        _result = result?.output ??
            'Resultado não disponível'; 
      });
    } catch (e) {
      setState(() {
        _result =
            'Erro ao processar a imagem: $e'; 
      });
    } finally {
      setState(() {
        _isLoading = false; 
        
        if (_result!.startsWith("```json")) {
          String clearResult = _result!.substring(7, _result!.length - 3);
          final jsonMap = jsonDecode(clearResult) as Map<String, dynamic>;
          final car = Car.fromJson(jsonMap);

          final userId = _auth.currentUser!.uid; // ID do usuário autenticado
          FirebaseFirestore.instance.collection('carHistory').add({
            'userId': userId,
            'marca': car.marca,
            'modelo': car.modelo,
            'ano': car.ano,
            'cor': car.cor,
            'timestamp': FieldValue.serverTimestamp(), 
          });

          Navigator.pushNamed(context, '/view', arguments: {
            'marca': car.marca,
            'modelo': car.modelo,
            'ano': car.ano,
            'cor': car.cor
          });
        } else {
          setState(() {
            errorText = "Erro ao processar a imagem";
          });
          
        }
      });
    }
  }

  
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    
    Navigator.of(context).pushReplacementNamed('/login');
  }

  
  Future<Uint8List?> _galleryImagePicker() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file != null) return await file.readAsBytes();
    return null;
  }

  
  Future<Uint8List?> _cameraImagePicker() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (file != null) return await file.readAsBytes();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CarSnap - Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Desconectar',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagem do App
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
            const Text(
              'Bem-vindo ao CarSnap!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final Uint8List? image =
                    await _galleryImagePicker(); 
                if (image != null) {
                  setState(() {
                    _imageBytes = image;
                  });
                  await _processImage();
                }
              },
              icon: const Icon(Icons.add_photo_alternate_rounded),
              label: const Text('Escolher da Galeria'),
            ),
            const SizedBox(height: 10),
            
            if (!kIsWeb)
              ElevatedButton.icon(
                onPressed: () async {
                  final Uint8List? image =
                      await _cameraImagePicker(); 
                  if (image != null) {
                    setState(() {
                      _imageBytes = image;
                    });
                    await _processImage();
                  }
                },
                icon: const Icon(Icons.add_a_photo_rounded),
                label: const Text('Tirar Foto'),
              ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/history');
              },
              icon: const Icon(Icons.history),
              label: const Text('Ver Histórico'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),

            Text(
              errorText,
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
