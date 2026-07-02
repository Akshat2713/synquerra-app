part of 'link_device_bloc.dart';

enum LinkDeviceStatus { idle, loading, success, error }

class LinkDeviceState extends Equatable {
  final LinkDeviceStatus status;
  final String? errorMessage;
  const LinkDeviceState({
    this.status = LinkDeviceStatus.idle,
    this.errorMessage,
  });

  LinkDeviceState copyWith({LinkDeviceStatus? status, String? errorMessage}) {
    return LinkDeviceState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
