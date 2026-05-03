import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class MiniGameScreen extends StatefulWidget {
  const MiniGameScreen({super.key});

  @override
  State<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen> {
  int _score = 0;
  int _lives = 3;
  double _patience = 1.0;
  String _currentComplaint = "";
  String _correctAnswer = "";
  Timer? _timer;
  bool _isGameOver = false;

  // Daftar keluhan pasien dan jawaban obat yang benar
  final Map<String, String> _challenges = {
    "Aduh, badan panas banget...": "Tablet",
    "Uhuk! Batuk nggak berhenti...": "Sirup",
    "Aww! Jatuh, lutut berdarah...": "Salep",
    "Kepala rasanya cekot-cekot...": "Kapsul",
  };

  @override
  void initState() {
    super.initState();
    _nextPatient();
    _startTimer();
  }

  void _nextPatient() {
    final random = Random();
    _currentComplaint = _challenges.keys.elementAt(random.nextInt(_challenges.length));
    _correctAnswer = _challenges[_currentComplaint]!;
    _patience = 1.0; // Reset kesabaran pasien baru
  }

  void _startTimer() {
    _timer?.cancel(); // Bersihin timer lama kalau ada
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        if (_patience > 0) {
          _patience -= 0.01; // Waktu berkurang
        } else {
          _wrongAnswer();
        }
      });
    });
  }

  void _checkAnswer(String medicine) {
    if (_isGameOver) return;
    if (medicine == _correctAnswer) {
      setState(() {
        _score += 10;
        _nextPatient();
      });
    } else {
      _wrongAnswer();
    }
  }

  void _wrongAnswer() {
    setState(() {
      _lives--;
      if (_lives <= 0) {
        _isGameOver = true;
        _timer?.cancel();
      } else {
        _nextPatient(); // Ganti pasien kalau masih ada nyawa
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Apoteker Express", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isGameOver ? _buildGameOver() : _buildGameContent(),
    );
  }

  Widget _buildGameContent() {
    return Column(
      children: [
        // --- SCORE & LIVES HEADER ---
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(10)),
                child: Text("Skor: $_score", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              Row(
                children: List.generate(3, (index) => Icon(
                  Icons.favorite, 
                  color: index < _lives ? Colors.red : Colors.grey.shade400,
                  size: 30,
                )),
              )
            ],
          ),
        ),
        
        // --- PATIENT AREA ---
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_circle, size: 120, color: Colors.blueGrey),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Text(
                    _currentComplaint, 
                    textAlign: TextAlign.center, 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 40),
                // Timer Kesabaran (Progress Bar)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Column(
                    children: [
                      const Text("Kesabaran Pasien", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _patience,
                          backgroundColor: Colors.grey.shade300,
                          color: _patience > 0.3 ? Colors.teal : Colors.red,
                          minHeight: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- MEDICINE TABLE (4 BUTTONS) ---
        Container(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -5))],
          ),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildMedsButton("Tablet", Icons.medication),
              _buildMedsButton("Sirup", Icons.local_drink),
              _buildMedsButton("Salep", Icons.clean_hands),
              _buildMedsButton("Kapsul", Icons.medication_liquid),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMedsButton(String name, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => _checkAnswer(name),
      icon: Icon(icon, size: 20),
      label: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0D9488), // Teal color
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
      ),
    );
  }

  Widget _buildGameOver() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sentiment_very_dissatisfied, size: 100, color: Colors.red),
          const SizedBox(height: 20),
          const Text("GAME OVER", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 10),
          Text("Skor Akhir: $_score", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _score = 0;
                _lives = 3;
                _isGameOver = false;
                _nextPatient();
                _startTimer();
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text("Main Lagi", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Keluar ke Menu", style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
    );
  }
}