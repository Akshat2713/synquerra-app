// presentation/pages/mode/modes_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../domain/entities/modes/mode_entity.dart';
import '../../blocs/modes/mode_bloc.dart';
import 'widgets/mode_list_tile.dart';
import 'widgets/mode_skeleton.dart';

class ModesScreen extends StatefulWidget {
  final String imei;
  final String currentModeName;
  const ModesScreen({
    super.key,
    required this.imei,
    required this.currentModeName,
  });

  @override
  State<ModesScreen> createState() => _ModesScreenState();
}

class _ModesScreenState extends State<ModesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ModeBloc>().add(ModeLoad(widget.currentModeName));
  }

  String? _getSelectedId(ModeState state) => switch (state) {
    ModeLoaded s => s.selectedModeId,
    ModeSwitching s => s.selectedModeId,
    ModeSwitchSuccess s => s.activeModeId,
    ModeSwitchFailure s => s.selectedModeId,
    _ => null,
  };

  List<ModeEntity> _getModes(ModeState state) => switch (state) {
    ModeLoaded s => s.modes,
    ModeSwitching s => s.modes,
    ModeSwitchSuccess s => s.modes,
    ModeSwitchFailure s => s.modes,
    _ => [],
  };

  void _onSave(BuildContext context, String? selectedId) {
    if (selectedId == null) return;
    context.read<ModeBloc>().add(
      ModeSwitchSubmit(imei: widget.imei, modeId: selectedId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Modes')),
      body: BlocConsumer<ModeBloc, ModeState>(
        listener: (context, state) {
          if (state is ModeSwitchSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Mode switched successfully.'),
                backgroundColor: colors.primary,
              ),
            );
          } else if (state is ModeSwitchFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          // ── Error ────────────────────────────────
          if (state is ModeError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: colors.error, size: 48),
                  const SizedBox(height: 12),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.read<ModeBloc>().add(
                      ModeLoad(widget.currentModeName),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final isLoading = state is ModeLoading || state is ModeInitial;
          final isSwitching = state is ModeSwitching;
          final modes = isLoading ? fakeModeSkeletonItems : _getModes(state);
          final selectedId = _getSelectedId(state);

          return Column(
            children: [
              // ── List ──────────────────────────────
              Expanded(
                child: Skeletonizer(
                  enabled: isLoading,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: modes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final mode = modes[index];
                      return ModeListTile(
                        mode: mode,
                        isSelected: selectedId == mode.id,
                        onTap: (isLoading || isSwitching)
                            ? () {}
                            : () => context.read<ModeBloc>().add(
                                ModeSelect(mode.id),
                              ),
                      );
                    },
                  ),
                ),
              ),

              // ── Save bar ──────────────────────────
              _SaveBar(
                enabled: selectedId != null && !isSwitching && !isLoading,
                isLoading: isSwitching,
                onSave: () => _onSave(context, selectedId),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Save bar ───────────────────────────────────────────────────────────────
class _SaveBar extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback onSave;

  const _SaveBar({
    required this.enabled,
    required this.isLoading,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: enabled ? onSave : null,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Apply Mode',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
      ),
    );
  }
}
