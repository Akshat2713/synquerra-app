import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../blocs/user_location/user_location_bloc.dart';
import '../../../themes/colors.dart';
import '../../../themes/app_tokens.dart';

import '../../../utils/app_icons.dart';

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
        final primary = AppColors.primary(context);
        return MarkerLayer(
          markers: [
            Marker(
              point: state.position,
              width: AppSize.avatarSm,
              height: AppSize.avatarSm,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.mapMarkerOutline,
                    width: AppSize.stroke,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppAlpha.withBorderAlpha(primary),
                      blurRadius: AppSpacing.sm,
                      spreadRadius: AppSpacing.xs,
                    ),
                  ],
                ),
                child: Icon(
                  AppIcons.userMarker,
                  color: AppColors.onPrimary(context),
                  size: AppSize.iconSm,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
