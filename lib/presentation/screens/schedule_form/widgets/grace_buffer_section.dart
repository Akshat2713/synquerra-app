import 'package:flutter/material.dart';

import 'package:synquerra/presentation/themes/app_tokens.dart';
import 'package:synquerra/presentation/utils/app_icons.dart';
import 'package:synquerra/presentation/widgets/app_surfaces.dart';
import 'package:synquerra/presentation/widgets/app_text_field.dart';

import 'section_header.dart';

class GraceBufferSection extends StatelessWidget {
  final TextEditingController arrivalGraceController;
  final TextEditingController departureBufferController;
  final TextEditingController minStayController;

  const GraceBufferSection({
    super.key,
    required this.arrivalGraceController,
    required this.departureBufferController,
    required this.minStayController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Grace & Buffer Rules'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.md,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.smd,
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: arrivalGraceController,
                      label: 'Arrival Grace',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Expanded(
                    child: AppTextField(
                      controller: departureBufferController,
                      label: 'Departure Buffer',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              AppTextField(
                controller: minStayController,
                label: 'Minimum Stay Duration',
                prefixIcon: AppIcons.time,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
