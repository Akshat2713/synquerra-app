import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../blocs/user_location/user_location_bloc.dart';
import '../../../themes/colors.dart';

class MapUserLocationLayer extends StatelessWidget {
  final UserLocationBloc userLocationBloc;

  const MapUserLocationLayer({super.key, required this.userLocationBloc});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserLocationBloc, UserLocationState>(
      bloc: userLocationBloc,
      builder: (context, state) {
        if (state is! UserLocationLoaded) {
          return const SizedBox.shrink();
        }
        return MarkerLayer(
          markers: [
            Marker(
              point: state.position,
              width: 32,
              height: 32,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
