import 'package:flutter/material.dart';
import 'package:vaxmanegr/features/system_stats/data/process_actions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:vaxmanegr/core/constants/app_colors.dart';
import 'package:vaxmanegr/core/constants/app_strings.dart';
import 'package:vaxmanegr/venom_layout.dart';

import '../cubit/system_stats_cubit.dart';
import '../widgets/stats_card.dart';
import '../widgets/process_action_sheet.dart';

class VaxmanegrScreen extends StatefulWidget {
  const VaxmanegrScreen({super.key});

  @override
  State<VaxmanegrScreen> createState() => _VaxmanegrScreenState();
}

class _VaxmanegrScreenState extends State<VaxmanegrScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return VenomScaffold(
      onSearchChanged: (query) {
        setState(() {
          _searchQuery = query;
        });
      },
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: BlocBuilder<SystemStatsCubit, SystemStatsState>(
                builder: (context, state) {
                  if (state is SystemStatsLoaded) {
                    return GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                      children: [
                        StatsCard(
                          title: AppStrings.cpu,
                          value: '',
                          unit: AppStrings.percentage,
                          color: AppColors.cpuColor,
                          icon: CupertinoIcons.settings,
                          dataPoints: state.cpuHistory,
                          child: Text(
                            state.stats.cpuUsage.toStringAsFixed(1),
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        StatsCard(
                          title: AppStrings.ram,
                          value: '',
                          unit: AppStrings.percentage,
                          color: AppColors.ramColor,
                          icon: Icons.memory,
                          dataPoints: state.memoryHistory,
                          child: Text(
                            state.stats.memoryUsage.toStringAsFixed(1),
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        StatsCard(
                          title: AppStrings.network,
                          value: '',
                          unit: AppStrings.networkPerSec,
                          color: AppColors.networkColor,
                          icon: CupertinoIcons.wifi,
                          dataPoints: state.networkDownloadHistory,
                          child: Text(
                            '${state.stats.networkDownload.toStringAsFixed(1)}/${state.stats.networkUpload.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        StatsCard(
                          title: AppStrings.disk,
                          value: '',
                          unit: AppStrings.megabytesPerSec,
                          color: AppColors.diskColor,
                          icon: CupertinoIcons.folder,
                          dataPoints: state.diskReadHistory,
                          child: Text(
                            '${state.stats.diskRead.toStringAsFixed(1)} /${state.stats.diskWrite.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return const Center(child: CupertinoActivityIndicator());
                },
              ),
            ),
            const SizedBox(height: 24),
            // Process List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                // AppStrings.processes,
                'Note: The RAM Usage field is for Flutter applications only; for other applications, their actual usage is shown in the RSS field.',
                style: TextStyle(
                  color: const Color.fromARGB(255, 58, 255, 189),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Header Row for Column Names
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Process Name',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'PID',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'CPU %',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'MEM %',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'RSS',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'RAM Usage',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'P.Clean',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<SystemStatsCubit, SystemStatsState>(
                builder: (context, state) {
                  if (state is SystemStatsLoaded) {
                    final filtered =
                        _searchQuery.isEmpty
                            ? state.processes
                            : state.processes
                                .where(
                                  (p) => p.name.toLowerCase().contains(
                                    _searchQuery.toLowerCase(),
                                  ),
                                )
                                .toList();
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final process = filtered[index];
                        return GestureDetector(
                          onLongPress: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder:
                                  (context) => ProcessActionSheet(
                                    onKill: () async {
                                      final messenger =
                                          ScaffoldMessenger.of(context);
                                      Navigator.pop(context);
                                      final msg =
                                          await ProcessActions.killProcess(
                                            process.pid,
                                          );
                                      if (!context.mounted) return;
                                      messenger.showSnackBar(
                                        SnackBar(content: Text(msg)),
                                      );
                                    },
                                    onShowLog: () async {
                                      final navigator = Navigator.of(context);
                                      Navigator.pop(context);
                                      final log =
                                          await ProcessActions.showProcessLog(
                                            process.pid,
                                          );
                                      if (!context.mounted) return;
                                      showDialog(
                                        context: context,
                                        builder:
                                          (context) => AlertDialog(
                                              title: Text(
                                                'Process ${process.pid} Log',
                                              ),
                                              content: SingleChildScrollView(
                                                child: Text(
                                                  log,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => navigator.pop(),
                                                  child: const Text('Close'),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
                                    onRestart: () async {
                                      final messenger =
                                          ScaffoldMessenger.of(context);
                                      Navigator.pop(context);
                                      final msg =
                                          await ProcessActions.restartProcess(
                                            process.pid,
                                          );
                                      if (!context.mounted) return;
                                      messenger.showSnackBar(
                                        SnackBar(content: Text(msg)),
                                      );
                                    },
                                  ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(171, 44, 44, 46),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    process.name,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    process.pid.toString(),
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${process.cpuUsage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${process.memoryUsage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                // RSS Memory Column
                                Expanded(
                                  child: Text(
                                    process.rssMb.toStringAsFixed(1),
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                        255,
                                        241,
                                        34,
                                        34,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                // Private Dirty Memory Column
                                Expanded(
                                  child: Text(
                                    process.privateDirtyMb.toStringAsFixed(1),
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                        255,
                                        0,
                                        255,
                                        242,
                                      ),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // Private Clean Memory Column
                                Expanded(
                                  child: Text(
                                    process.privateCleanMb.toStringAsFixed(1),
                                    style: TextStyle(
                                      color: AppColors.networkColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: CupertinoActivityIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
