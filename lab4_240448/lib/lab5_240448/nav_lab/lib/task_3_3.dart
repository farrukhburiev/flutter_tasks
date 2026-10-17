import 'package:flutter/material.dart';

class Contact {
  final String name;
  final String phone;
  final String email;
  const Contact({
    required this.name,
    required this.phone,
    required this.email,
  });
}

const contacts = [
  Contact(name: 'Alice Johnson', phone: '+1 555 0101', email: 'alice@mail.com'),
  Contact(name: 'Bob Smith', phone: '+1 555 0102', email: 'bob@mail.com'),
  Contact(name: 'Carol White', phone: '+1 555 0103', email: 'carol@mail.com'),
  Contact(name: 'David Brown', phone: '+1 555 0104', email: 'david@mail.com'),
  Contact(name: 'Eve Black', phone: '+1 555 0105', email: 'eve@mail.com'),
];

Widget buildApp() => const MaterialApp(home: ContactListScreen());

class ContactListScreen extends StatelessWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            leading: CircleAvatar(child: Text(contact.name[0])),
            title: Text(contact.name),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ContactScreen(contact: contact),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ContactScreen extends StatelessWidget {
  final Contact contact;
  const ContactScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contact.name)),
      body: Center(
        child: Card(
          elevation: 6,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  child: Text(
                    contact.name[0],
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(contact.phone),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(contact.email),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
