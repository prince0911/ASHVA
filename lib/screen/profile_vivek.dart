import 'package:flutter/material.dart';
import 'package:resq_assist/screen/edit_profile_screen.dart';
class ProfileVivekScreen extends StatelessWidget {
  const ProfileVivekScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
        currentIndex: 3,
      ),
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/profile.jpg'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Parves Ahamad',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              '@parvesahmad',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
              child: const Text('Edit Profile'),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const ProfileTile(icon: Icons.settings, label: 'Settings'),
            const ProfileTile(icon: Icons.shopping_bag, label: 'My Orders'),
            const ProfileTile(icon: Icons.location_on, label: 'Address'),
            const ProfileTile(icon: Icons.lock, label: 'Change Password'),
            const ProfileTile(icon: Icons.help_outline, label: 'Help & Support'),
            const ProfileTile(icon: Icons.logout, label: 'Log out'),
          ],
        ),
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const ProfileTile({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
}