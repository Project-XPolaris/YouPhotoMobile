import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:youphotomobile/api/client.dart';
import 'package:youphotomobile/config.dart';
import 'package:crypto/crypto.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final ApiClient _apiClient = ApiClient();

  AppBloc() : super(const AppInitial()) {
    on<ToggleOfflineModeEvent>((event, emit) {
      // 当前处于离线状态
      emit(state.copyWith(isOffline: event.isOffline));
    });

    on<CheckServerStateEvent>((event, emit) async {
      // emit(state.copyWith(isOffline: true));
      try {
        await _apiClient.fetchState();
        emit(state.copyWith(isOffline: false));
        ApplicationConfig().isOffline = false;
      } catch (e) {
        emit(state.copyWith(isOffline: true));
        ApplicationConfig().isOffline = true;
      }
    });

    on<AddSyncTaskEvent>((event, emit) {
      final currentQueue = List<SyncTask>.from(state.syncQueue);
      currentQueue.add(event.task);
      emit(state.copyWith(syncQueue: currentQueue));

      // 如果当前没有在同步，则开始处理队列
      if (!state.isSyncing) {
        add(const ProcessSyncQueueEvent());
      }
    });

    on<ProcessSyncQueueEvent>((event, emit) async {
      if (state.syncQueue.isEmpty || state.isSyncing) return;

      emit(state.copyWith(isSyncing: true));

      while (state.syncQueue.isNotEmpty) {
        final task = state.syncQueue.first;
        try {
          // 处理单个同步任务
          await _processSyncTask(task);

          // 任务成功后从队列中移除
          final currentQueue = List<SyncTask>.from(state.syncQueue);
          currentQueue.removeAt(0); // 移除已完成的任务
          emit(state.copyWith(syncQueue: currentQueue));

          // 如果队列为空，结束同步状态
          if (currentQueue.isEmpty) {
            emit(state.copyWith(isSyncing: false));
          }
        } catch (e) {
          print('同步任务失败: ${e.toString()}');
          // 如果任务失败，将状态设置为离线
          // emit(state.copyWith(isOffline: true, isSyncing: false));
          // ApplicationConfig().isOffline = true;
          return;
        }
      }

      // 所有任务处理完成
      emit(state.copyWith(isSyncing: false));
    });

    on<RemoveSyncTaskEvent>((event, emit) {
      final currentQueue = List<SyncTask>.from(state.syncQueue);
      currentQueue.removeWhere((task) => task.id == event.taskId);
      emit(state.copyWith(syncQueue: currentQueue));
    });

    on<UpdateTaskProgressEvent>((event, emit) {
      final currentQueue = List<SyncTask>.from(state.syncQueue);
      final taskIndex =
          currentQueue.indexWhere((task) => task.id == event.taskId);

      if (taskIndex != -1) {
        currentQueue[taskIndex] = currentQueue[taskIndex].copyWith(
          progress: event.progress,
          statusMessage: event.statusMessage,
        );
        emit(state.copyWith(syncQueue: currentQueue));
      }
    });
  }

  Future<bool> doUpload(AssetPathEntity entity, List<AssetEntity> assets,
      int libraryId, String taskId) async {
    for (var index = 0; index < assets.length; index++) {
      var asset = assets[index];
      var file = await asset.file;
      if (file == null) {
        continue;
      }

      // 计算并更新进度
      double progress = (index + 1) / assets.length;
      add(UpdateTaskProgressEvent(
        taskId: taskId,
        progress: progress,
        statusMessage: '正在上传第 ${index + 1}/${assets.length} 个文件',
      ));

      var fileBytes = await file.readAsBytes();

      var fileName = file.path.split("/").last;
      try {
        var fileMd5 = md5.convert(fileBytes);
        var resp = await ApiClient().fetchImageList(
            {"md5": fileMd5.toString(), "libraryId": libraryId.toString()});
        if ((resp.count ?? 0) > 0) {
          continue;
        }
        await ApiClient().uploadImage(fileBytes, fileName, libraryId,
            albumName: entity.name);
      } catch (e) {
        print(e);
      }
    }
    // NotificationPlugin().flutterLocalNotificationsPlugin?.cancel(0);
    return true;
  }

  Future<void> _processSyncTask(SyncTask task) async {
    print('开始处理任务: ${task.id} - 类型: ${task.type}');
    // 根据任务类型处理不同的同步逻辑
    switch (task.type) {
      case 'upload':
        await doUpload(
          task.data['entity'],
          task.data['assets'],
          task.data['libraryId'],
          task.id,
        );
        break;
      default:
        throw Exception('Unknown sync task type: ${task.type}');
    }
    print('任务完成: ${task.id}');
  }
}
