import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/colors.dart';

import '../../../data/models/signup/person_model.dart';

class ProfileScreen extends StatelessWidget {
  final PersonModel? person;

  const ProfileScreen({super.key, this.person});

  @override
  Widget build(BuildContext context) {
    // Fallback to default/mock user if null
    final user = person ?? defaultUser;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: Navigate to Edit Profile screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            _buildProfileHeader(context, user),
            const SizedBox(height: 24),
            _buildPersonalDetailsCard(context, user),
            const SizedBox(height: 16),
            _buildAddressCard(context, user),
            const SizedBox(height: 16),
            _buildScheduleCard(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Header with Avatar, Full Name, Email, and Unique ID Tag
  Widget _buildProfileHeader(BuildContext context, PersonModel user) {
    final String fullName = '${user.firstName} ${user.lastName}'.trim();

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryContainer,
              backgroundImage:
                  user.profilePhoto != null && user.profilePhoto!.isNotEmpty
                  ? NetworkImage(user.profilePhoto!)
                  : null,
              child: user.profilePhoto == null || user.profilePhoto!.isEmpty
                  ? Text(
                      user.firstName.isNotEmpty
                          ? user.firstName[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimaryContainer(context),
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface(context),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          fullName.isNotEmpty ? fullName : 'User Profile',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 4),
        if (user.email != null)
          Text(
            user.email!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
      ],
    );
  }

  // Personal Information Section
  Widget _buildPersonalDetailsCard(BuildContext context, PersonModel user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              'Personal Information',
              Icons.person_outline,
            ),
            const Divider(height: 24),
            _buildInfoRow(context, 'Phone', user.phone ?? user.mobile ?? 'N/A'),
            _buildInfoRow(
              context,
              'Gender',
              user.gender?.capitalize() ?? 'N/A',
            ),
            _buildInfoRow(
              context,
              'Birth Date',
              user.birthDate ?? 'N/A',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  // Address Details Section
  Widget _buildAddressCard(BuildContext context, PersonModel user) {
    final hasAddress =
        user.address != null ||
        user.city != null ||
        user.state != null ||
        user.country != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              'Address Details',
              Icons.location_on_outlined,
            ),
            const Divider(height: 24),
            if (hasAddress) ...[
              _buildInfoRow(context, 'Street Address', user.address ?? 'N/A'),
              _buildInfoRow(context, 'City', user.city ?? 'N/A'),
              _buildInfoRow(context, 'State', user.state ?? 'N/A'),
              _buildInfoRow(context, 'Country', user.country ?? 'N/A'),
              _buildInfoRow(
                context,
                'Pincode',
                user.pincode ?? 'N/A',
                isLast: true,
              ),
            ] else
              Text(
                'No address details provided',
                style: TextStyle(color: AppColors.textTertiary(context)),
              ),
          ],
        ),
      ),
    );
  }

  // Schedule Section
  Widget _buildScheduleCard(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to Schedule / Calendar page
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'View and manage active schedules',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Section Header Helper
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  // Key-Value Info Row Helper
  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Logout Button
}

// Private mock instance used as fallback
final defaultUser = PersonModel(
  id: 'usr_123',
  uniqueId: 'SYN-8842',
  firstName: 'John',
  lastName: 'Doe',
  email: 'john.doe@synquerra.com',
  phone: '+1 234 567 890',
  birthDate: '1990-01-01',
  gender: 'Male',
  address: '123 Main St',
  city: 'Springfield',
  state: 'OR',
  country: 'USA',
  pincode: '97477',
  profilePhoto: null,
  role: 'Field Operator',
  userType: 'Primary',
  isActive: true,
  isEmailVerified: true,
  isMobileVerified: true,
);

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
