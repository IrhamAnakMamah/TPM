import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Data lokal yang bisa diedit
  String _userName = 'Yusuf Nur Ramadhan';
  String _userEmail = '123230188@student.upnyk.ac.id';
  bool _isNotificationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 40, bottom: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 55,
                        backgroundColor: Color(0xFF0D9488),
                        child: Text('YN', style: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      GestureDetector(
                        onTap: () => _showSnackBar('Membuka Galeri Foto...'),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(_userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const Text('123230188 | Informatika', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 20),
                  
                  // FITUR AKTIF: EDIT PROFIL
                  SizedBox(
                    width: 160,
                    child: ElevatedButton.icon(
                      onPressed: () => _showEditProfileDialog(),
                      icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                      label: const Text('Edit Profil', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- MENU SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Informasi Akademik', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildInfoTile(Icons.school, 'Universitas Pembangunan Nasional'),
                  _buildInfoTile(Icons.email, _userEmail),
                  
                  const SizedBox(height: 25),
                  const Text('Pengaturan Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  
                  // FITUR AKTIF: GANTI PASSWORD
                  _buildMenuTile(Icons.lock_outline, 'Ganti Password', Colors.blue, () => _showChangePasswordDialog()),
                  
                  // FITUR AKTIF: NOTIFIKASI
                  _buildMenuTile(
                    _isNotificationEnabled ? Icons.notifications_active : Icons.notifications_off, 
                    'Notifikasi Pengingat', 
                    Colors.orange, 
                    () => _toggleNotification()
                  ),
                  
                  // FITUR AKTIF: EVALUASI (BOTTOM SHEET)
                  _buildMenuTile(Icons.feedback_outlined, 'Evaluasi & Masukan', Colors.purple, () => _showEvaluationSheet()),
                  
                  // FITUR AKTIF: LOGOUT
                  _buildMenuTile(Icons.logout, 'Keluar Akun', Colors.red, () => _showLogoutConfirm(), isLogout: true),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- LOGIKA FITUR (FUNCTIONS) ---

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  void _showEditProfileDialog() {
    TextEditingController nameCtrl = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Nama Profil'),
        content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              setState(() => _userName = nameCtrl.text);
              Navigator.pop(context);
              _showSnackBar('Profil diperbarui!');
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ganti Password'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password Lama')),
            TextField(obscureText: true, decoration: InputDecoration(labelText: 'Password Baru')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(onPressed: () { Navigator.pop(context); _showSnackBar('Password berhasil diganti!'); }, child: const Text('Update')),
        ],
      ),
    );
  }

  void _toggleNotification() {
    setState(() => _isNotificationEnabled = !_isNotificationEnabled);
    _showSnackBar(_isNotificationEnabled ? 'Notifikasi Aktif' : 'Notifikasi Dimatikan');
  }

  void _showEvaluationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Evaluasi & Masukan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const TextField(maxLines: 3, decoration: InputDecoration(hintText: 'Tulis kesan kuliah TPM...', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Kirim'))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Aplikasi?'),
        content: const Text('Anda akan diarahkan kembali ke halaman login.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/'), child: const Text('Keluar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildInfoTile(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(children: [Icon(icon, color: Colors.teal, size: 20), const SizedBox(width: 15), Text(text)]),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, Color color, VoidCallback onTap, {bool isLogout = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: isLogout ? Colors.red : Colors.black87)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}