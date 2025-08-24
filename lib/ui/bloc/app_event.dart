part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object?> get props => [];
}

class ToggleOfflineModeEvent extends AppEvent {
  final bool isOffline;

  const ToggleOfflineModeEvent({required this.isOffline});

  @override
  List<Object?> get props => [isOffline];
}

class CheckServerStateEvent extends AppEvent {
  const CheckServerStateEvent();
}

class AddSyncTaskEvent extends AppEvent {
  final SyncTask task;

  const AddSyncTaskEvent({required this.task});

  @override
  List<Object?> get props => [task];
}

class ProcessSyncQueueEvent extends AppEvent {
  const ProcessSyncQueueEvent();
}

class RemoveSyncTaskEvent extends AppEvent {
  final String taskId;

  const RemoveSyncTaskEvent({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

class UpdateTaskProgressEvent extends AppEvent {
  final String taskId;
  final double progress;
  final String? statusMessage;

  const UpdateTaskProgressEvent({
    required this.taskId,
    required this.progress,
    this.statusMessage,
  });

  @override
  List<Object?> get props => [taskId, progress, statusMessage];
}
