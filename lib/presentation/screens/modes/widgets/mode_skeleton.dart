// presentation/pages/mode/widgets/mode_skeleton.dart
import '../../../../domain/entities/modes/mode_entity.dart';

final fakeModeSkeletonItems = List.generate(
  3,
  (i) => ModeEntity(
    id: 'skeleton_$i',
    name: 'Loading Mode Name',
    description: 'Loading description text here',
    normalSendingInterval: 1800,
    sosSendingInterval: 300,
    normalScanningInterval: 900,
    airplaneInterval: 30,
    temperatureLimit: 50,
    speedLimit: 70,
    lowbatLimit: 20,
    categories: const [],
    note: '',
    priority: 50,
    reconfirmationTime: 10,
    airplaneMode: false,
    ambientListeningStatus: 'Stop',
    ledStatus: false,
    isActive: false,
    isDefault: false,
    createdAt: '',
    updatedAt: '',
  ),
);
