// lib/presentation/screens/main_shell/main_shell_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

/// Holds the selected bottom-navigation index.
class MainShellCubit extends Cubit<int> {
  MainShellCubit() : super(0);

  void select(int index) {
    if (index != state) emit(index);
  }
}
