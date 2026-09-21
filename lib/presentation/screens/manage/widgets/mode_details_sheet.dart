// lib/presentation/screens/manage/widgets/mode_details_sheet.dart

import 'package:flutter/material.dart';
import '../../../../domain/entities/modes/mode_entity.dart';
import '../../../themes/colors.dart';

void showModeDetailsSheet(BuildContext context, ModeEntity mode) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ModeDetailsSheet(mode: mode),
  );
}

class ModeDetailsSheet extends StatelessWidget {
  final ModeEntity mode;

  const ModeDetailsSheet({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  mode.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          if (mode.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              mode.description,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
          const Divider(height: 24),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildSectionHeader(context, 'Intervals'),
                _buildDetailRow(
                  context,
                  'Normal Sending',
                  '${mode.normalSendingInterval}s',
                ),
                _buildDetailRow(
                  context,
                  'SOS Sending',
                  '${mode.sosSendingInterval}s',
                ),
                _buildDetailRow(
                  context,
                  'Normal Scanning',
                  '${mode.normalScanningInterval}s',
                ),
                _buildDetailRow(
                  context,
                  'Airplane Interval',
                  '${mode.airplaneInterval}s',
                ),

                _buildSectionHeader(context, 'Limits & Thresholds'),
                _buildDetailRow(
                  context,
                  'Temperature Limit',
                  '${mode.temperatureLimit} ℃',
                ),
                _buildDetailRow(
                  context,
                  'Speed Limit',
                  '${mode.speedLimit} km/h',
                ),
                _buildDetailRow(
                  context,
                  'Low Battery Limit',
                  '${mode.lowbatLimit}%',
                ),

                _buildSectionHeader(context, 'Configuration & Status'),
                _buildDetailRow(context, 'Priority', mode.priority.toString()),
                _buildDetailRow(
                  context,
                  'Reconfirmation Time',
                  '${mode.reconfirmationTime}s',
                ),
                _buildDetailRow(
                  context,
                  'Airplane Mode',
                  mode.airplaneMode ? 'Enabled' : 'Disabled',
                ),
                _buildDetailRow(
                  context,
                  'Ambient Listening',
                  mode.ambientListeningStatus,
                ),
                _buildDetailRow(
                  context,
                  'LED Status',
                  mode.ledStatus ? 'Enabled' : 'Disabled',
                ),

                if (mode.note.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Note'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      mode.note,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary(context),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}
