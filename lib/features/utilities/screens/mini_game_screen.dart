import 'package:flutter/material.dart';

class MiniGameScreen extends StatefulWidget {
  const MiniGameScreen({super.key});

  @override
  State<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen> {
  int _score = 0;
  String _currentPill = '🔴'; // Target obat yang harus diklik
  String _message = 'Klik pil MERAH untuk skor!';

  void _onPillClicked(String pillType) {
    setState(() {
      if (pillType == _currentPill) {
        _score += 10;
        _message = 'Bagus! Lanjut...';
      } else {
        _score -= 5;
        _message = 'Salah klik! Fokus, fokus...';
      }
      // Logika game sederhana: Target acak
      _currentPill = (DateTime.now().second % 2 == 0) ? '🔴' : '🔵';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('MedMatch Pro'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.bold),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // --- BACKGROUND DECORATION ---
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.teal.shade50,
                  const Color(0xFFF8FAFC),
                ],
              ),
            ),
          ),

          // --- MAIN CONTENT ---
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  // --- HEADER: LOGO & SCORE ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Icon(Icons.sports_esports_rounded, color: Colors.teal.shade700, size: 28),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Text(
                          'Skor: $_score',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),

                  // --- GAME AREA ---
                  Container(
                    padding: const EdgeInsets.all(25.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.medication_rounded, size: 80, color: Colors.teal),
                        const SizedBox(height: 15),
                        const Text(
                          'Cari Pasangan Obat',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          _message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 30),

                        // --- INTERACTIVE BUTTONS ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPillButton('🔴', Colors.red),
                            _buildPillButton('🔵', Colors.blue),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // --- RESTART BUTTON ---
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _score = 0;
                                _message = 'Klik pil MERAH untuk skor!';
                                _currentPill = '🔴';
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: const Text('Mulai Ulang Game', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // --- KETERANGAN GAME ---
                  const Text(
                    'Cara Bermain:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Klik pil yang warnanya sama dengan target di pesan atas.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillButton(String pill, Color pillColor) {
    return InkWell(
      onTap: () => _onPillClicked(pill),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: pillColor.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Text(
          pill,
          style: TextStyle(fontSize: 32, color: pillColor),
        ),
      ),
    );
  }
}