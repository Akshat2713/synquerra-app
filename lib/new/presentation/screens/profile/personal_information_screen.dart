// lib/presentation/screens/profile/personal_information_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synquerra/new/presentation/widgets/common/detail_row.dart';
import 'package:synquerra/new/presentation/widgets/common/info_container.dart';
import '../../../business/blocs/auth_bloc/auth_bloc.dart';
import '../../widgets/profile/profile_avatar.dart';

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      appBar: AppBar(title: const Text("Personal Information")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          Row(
            children: [
              ProfileAvatar(name: user?.fullName ?? 'User', size: 80),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'User Name',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.imei ?? 'No Device',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // User Details
          InfoContainer(
            title: "User Details",
            children: [
              DetailRow(
                icon: Icons.person,
                title: "Name",
                value: user?.fullName ?? "User Name",
              ),
              const SizedBox(height: 12),
              DetailRow(
                icon: Icons.badge,
                title: "User ID",
                value: user?.uniqueId ?? "N/A",
              ),
              const SizedBox(height: 12),
              DetailRow(
                icon: Icons.email,
                title: "Email",
                value: user?.email ?? "user@example.com",
              ),
              const SizedBox(height: 12),
              DetailRow(
                icon: Icons.phone,
                title: "Phone",
                value: user?.mobile ?? "N/A",
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Address Information (Placeholder)
          InfoContainer(
            title: "Address Information",
            children: [
              DetailRow(
                icon: Icons.location_on,
                title: "Address",
                value: "Dudura, Jammu",
              ),
              const SizedBox(height: 12),
              DetailRow(
                icon: Icons.location_city,
                title: "City",
                value: "Jammu",
              ),
              const SizedBox(height: 12),
              DetailRow(icon: Icons.map, title: "State", value: "J&K"),
              const SizedBox(height: 12),
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
}
