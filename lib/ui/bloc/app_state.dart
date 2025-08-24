part of 'app_bloc.dart';

class AppState extends Equatable {
  final bool isOffline;
  final List<SyncTask> syncQueue;
  final bool isSyncing;

  const AppState({
    this.isOffline = false,
    this.syncQueue = const [],
    this.isSyncing = false,
  });

  @override
  List<Object?> get props => [isOffline, syncQueue, isSyncing];

  AppState copyWith({
    bool? isOffline,
    List<SyncTask>? syncQueue,
    bool? isSyncing,
  }) {
    return AppState(
      isOffline: isOffline ?? this.isOffline,
      syncQueue: syncQueue ?? this.syncQueue,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

class AppInitial extends AppState {
  const AppInitial() : super(isOffline: false);
}

class SyncTask extends Equatable {
  final String id;
  final String type;
  final dynamic data;
  final DateTime createdAt;
  final double progress;
  final String? statusMessage;

  const SyncTask({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.progress = 0.0,
    this.statusMessage,
  });

  @override
  List<Object?> get props =>
      [id, type, data, createdAt, progress, statusMessage];

  SyncTask copyWith({
    double? progress,
    String? statusMessage,
  }) {
    return SyncTask(
      id: id,
      type: type,
      data: data,
      createdAt: createdAt,
      progress: progress ?? this.progress,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
