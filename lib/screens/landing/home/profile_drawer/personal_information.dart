import 'package:flutter/material.dart';
import 'package:safe_track/widgets/info_card.dart'; // IMPORT the new reusable widgets

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Profile")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- TOP PROFILE HEADER (BIGGER) ---
          _buildProfileHeader(context),
          const SizedBox(height: 24),

          // --- ADDED: THE DIVIDER LINE ---
          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: 24),

          // --- USER DETAILS CONTAINER ---
          InfoContainer(
            // Use the new reusable widget
            title: "User Details",
            children: const [
              DetailRow(
                icon: Icons.person,
                title: "Name",
                value: "Rohan Sharma",
              ),
              DetailRow(icon: Icons.badge, title: "User ID", value: "GHY782B1"),
              DetailRow(
                icon: Icons.label,
                title: "Device Label",
                value: "Rohan's Tracker",
              ),
              DetailRow(
                icon: Icons.cake,
                title: "Date of Birth",
                value: "25-Aug-2011",
              ),
              DetailRow(icon: Icons.wc, title: "Gender", value: "Male"),
              DetailRow(
                icon: Icons.credit_card,
                title: "AADHAR",
                value: "5678-XXXX-XXXX",
              ),
              DetailRow(
                icon: Icons.app_registration,
                title: "APAAR",
                value: "Not Linked",
              ),
              DetailRow(
                icon: Icons.email,
                title: "Email",
                value: "rohan.sharma@email.com",
              ),
              DetailRow(icon: Icons.phone, title: "Phone", value: "9876543210"),
              DetailRow(
                icon: Icons.location_on,
                title: "Address",
                value: "Dudura, Jammu",
              ),
              DetailRow(
                icon: Icons.location_city,
                title: "City",
                value: "Jammu",
              ),
              DetailRow(icon: Icons.map, title: "State", value: "J&K"),
              DetailRow(
                icon: Icons.local_post_office,
                title: "PIN Code",
                value: "181221",
              ),
            ],
          ),

          // --- GUARDIAN 1 DETAILS CONTAINER ---
          InfoContainer(
            title: "Guardian 1 Details",
            children: const [
              DetailRow(
                icon: Icons.person,
                title: "Name",
                value: "Mr. Vijay Sharma",
              ),
              DetailRow(
                icon: Icons.badge,
                title: "User ID",
                value: "G1-ABCDE123",
              ),
              DetailRow(
                icon: Icons.credit_card,
                title: "AADHAR",
                value: "1234-XXXX-XXXX",
              ),
              DetailRow(
                icon: Icons.email,
                title: "Email",
                value: "v.sharma@email.com",
              ),
              DetailRow(icon: Icons.phone, title: "Phone", value: "9988776655"),
              DetailRow(
                icon: Icons.location_on,
                title: "Address",
                value: "Dudura, Jammu",
              ),
              DetailRow(
                icon: Icons.location_city,
                title: "City",
                value: "Jammu",
              ),
              DetailRow(icon: Icons.map, title: "State", value: "J&K"),
              DetailRow(
                icon: Icons.local_post_office,
                title: "PIN Code",
                value: "181221",
              ),
            ],
          ),

          // --- GUARDIAN 2 DETAILS CONTAINER ---
          InfoContainer(
            title: "Guardian 2 Details",
            children: const [
              DetailRow(
                icon: Icons.person,
                title: "Name",
                value: "Mrs. Priya Sharma",
              ),
              DetailRow(
                icon: Icons.badge,
                title: "User ID",
                value: "G2-FGHIJ456",
              ),
              DetailRow(
                icon: Icons.credit_card,
                title: "AADHAR",
                value: "2345-XXXX-XXXX",
              ),
              DetailRow(
                icon: Icons.email,
                title: "Email",
                value: "p.sharma@email.com",
              ),
              DetailRow(icon: Icons.phone, title: "Phone", value: "9988776644"),
              DetailRow(
                icon: Icons.location_on,
                title: "Address",
                value: "Dudura, Jammu",
              ),
              DetailRow(
                icon: Icons.location_city,
                title: "City",
                value: "Jammu",
              ),
              DetailRow(icon: Icons.map, title: "State", value: "J&K"),
              DetailRow(
                icon: Icons.local_post_office,
                title: "PIN Code",
                value: "181221",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET FOR THE BIGGER TOP PROFILE HEADER ---
  Widget _buildProfileHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 40, // CHANGED: Bigger radius
          backgroundColor: colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.person,
            size: 50, // CHANGED: Bigger icon
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Rohan Sharma",
                style: TextStyle(
                  fontSize: 26, // CHANGED: Bigger font
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "GHY782B1",
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
