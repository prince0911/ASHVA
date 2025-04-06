import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.grey),
    );

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Edit Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/images/profile.jpg'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Parves Ahamad',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Text(
              '@parvesahmad',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Full Name
            TextField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: inputBorder,
              ),
            ),
            const SizedBox(height: 10),

            // Gender and Birthday
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      border: inputBorder,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Birthday',
                      border: inputBorder,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Phone Number
            TextField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: inputBorder,
              ),
            ),
            const SizedBox(height: 10),

            // Email
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: inputBorder,
              ),
            ),
            const SizedBox(height: 10),

            // User Name
            TextField(
              decoration: InputDecoration(
                labelText: 'User Name',
                border: inputBorder,
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {},
                child: const Text('Save'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
