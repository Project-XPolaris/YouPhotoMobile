import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youphotomobile/ui/bloc/app_bloc.dart';
import 'package:flutter/services.dart';

class SyncTaskBottomSheet extends StatelessWidget {
  const SyncTaskBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.android) {
      SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) async {
        return;
      });
    }

    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '同步任务列表',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (state.isSyncing)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (state.syncQueue.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('暂无同步任务'),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.syncQueue.length,
                    itemBuilder: (context, index) {
                      final task = state.syncQueue[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: _getTaskIcon(task.type),
                                title: Text('任务 #${index + 1}'),
                                subtitle: Text(
                                  '类型: ${task.type}\n创建时间: ${task.createdAt.toString().split('.')[0]}',
                                ),
                                isThreeLine: true,
                              ),
                              if (task.statusMessage != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Text(
                                    task.statusMessage!,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: LinearProgressIndicator(
                                  value: task.progress,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  bottom: 8.0,
                                ),
                                child: Text(
                                  '${(task.progress * 100).toStringAsFixed(1)}%',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _getTaskIcon(String type) {
    switch (type) {
      case 'upload':
        return const Icon(Icons.upload_file);
      default:
        return const Icon(Icons.sync);
    }
  }
}
