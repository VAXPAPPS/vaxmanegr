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

class vaxmanegrScreen extends StatefulWidget {
  const vaxmanegrScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _vaxmanegrScreenState createState() => _vaxmanegrScreenState();
}

class _vaxmanegrScreenState extends State<vaxmanegrScreen> {
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
                          child: BlocBuilder<SystemStatsCubit, SystemStatsState>(
                            builder: (context, state) {
                              if (state is SystemStatsLoaded) {
                                return Text(
                                  state.stats.cpuUsage.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                              return const Text('0.0');
                            },
                          ),
                        ),
                        StatsCard(
                          title: AppStrings.ram,
                          value: '',
                          unit: AppStrings.percentage,
                          color: AppColors.ramColor,
                          icon: Icons.memory,
                          child: BlocBuilder<SystemStatsCubit, SystemStatsState>(
                            builder: (context, state) {
                              if (state is SystemStatsLoaded) {
                                return Text(
                                  state.stats.memoryUsage.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                              return const Text('0.0');
                            },
                          ),
                        ),
                        StatsCard(
                          title: AppStrings.network,
                          value: '',
                          unit: AppStrings.networkPerSec,
                          color: AppColors.networkColor,
                          icon: CupertinoIcons.wifi,
                          child: BlocBuilder<SystemStatsCubit, SystemStatsState>(
                            builder: (context, state) {
                              if (state is SystemStatsLoaded) {
                                return Text(
                                  '${state.stats.networkDownload.toStringAsFixed(1)}/${state.stats.networkUpload.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                              return const Text('0.0/0.0');
                            },
                          ),
                        ),
                        StatsCard(
                          title: AppStrings.disk,
                          value: '',
                          unit: AppStrings.megabytesPerSec,
                          color: AppColors.diskColor,
                          icon: CupertinoIcons.folder,
                          child: BlocBuilder<SystemStatsCubit, SystemStatsState>(
                            builder: (context, state) {
                              if (state is SystemStatsLoaded) {
                                return Text(
                                  '${state.stats.diskRead.toStringAsFixed(1)} /${state.stats.diskWrite.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                              return const Text('0.0/0.0');
                            },
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
                AppStrings.processes,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<SystemStatsCubit, SystemStatsState>(
                builder: (context, state) {
                  if (state is SystemStatsLoaded) {
                    final filtered = _searchQuery.isEmpty
                        ? state.processes
                        : state.processes.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
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
                              builder: (context) => ProcessActionSheet(
                                onKill: () async {
                                  Navigator.pop(context);
                                  final msg = await ProcessActions.killProcess(process.pid);
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(msg)),
                                  );
                                },
                                onShowLog: () async {
                                  Navigator.pop(context);
                                  final log = await ProcessActions.showProcessLog(process.pid);
                                  showDialog(
                                    // ignore: use_build_context_synchronously
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Process ${process.pid} Log'),
                                      content: SingleChildScrollView(child: Text(log, style: const TextStyle(fontSize: 12))),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onRestart: () async {
                                  Navigator.pop(context);
                                  final msg = await ProcessActions.restartProcess(process.pid);
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
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
                                Expanded(
                                  child: Text(
                                    '${process.ramMb.toStringAsFixed(1)} MB',
                                    style: TextStyle(
                                      color: AppColors.networkColor,
                                      fontWeight: FontWeight.bold,
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