import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/system_stats_model.dart';
import '../../data/repositories/system_stats_repository.dart';

/// ====== States ======
abstract class SystemStatsState extends Equatable {
  @override
  List<Object> get props => [];
}

class SystemStatsInitial extends SystemStatsState {}

class SystemStatsLoading extends SystemStatsState {}

class SystemStatsLoaded extends SystemStatsState {
  final SystemStats stats;
  final List<ProcessInfo> processes;
  final List<double> cpuHistory;
  final List<double> memoryHistory;
  final List<double> networkDownloadHistory;
  final List<double> networkUploadHistory;
  final List<double> diskReadHistory;
  final List<double> diskWriteHistory;

   SystemStatsLoaded({
    required this.stats,
    required this.processes,
    this.cpuHistory = const [],
    this.memoryHistory = const [],
    this.networkDownloadHistory = const [],
    this.networkUploadHistory = const [],
    this.diskReadHistory = const [],
    this.diskWriteHistory = const [],
  });

  @override
  List<Object> get props => [
    stats,
    processes,
    cpuHistory,
    memoryHistory,
    networkDownloadHistory,
    networkUploadHistory,
    diskReadHistory,
    diskWriteHistory,
  ];
}

class SystemStatsError extends SystemStatsState {
  final String message;

   SystemStatsError(this.message);

  @override
  List<Object> get props => [message];
}

/// ====== Cubit ======
class SystemStatsCubit extends Cubit<SystemStatsState> {
  final SystemStatsRepository repository;
  Timer? _timer;
  
  // History lists for charts
  final List<double> _cpuHistory = [];
  final List<double> _memoryHistory = [];
  final List<double> _networkDownloadHistory = [];
  final List<double> _networkUploadHistory = [];
  final List<double> _diskReadHistory = [];
  final List<double> _diskWriteHistory = [];
  
  static const int _maxHistoryLength = 20; // Keep last 20 data points

  SystemStatsCubit(this.repository) : super(SystemStatsInitial()) {
    startUpdates();
  }

  void startUpdates() {
    _timer?.cancel();
    // يمكنك تغيير المدة هنا حسب رغبتك
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      fetchStats();
    });
    // تحميل أول مرة
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      // فقط في البداية نعرض Loading
      if (state is SystemStatsInitial) {
        emit(SystemStatsLoading());
      }

      final stats = await repository.getSystemStats();
      final processes = await repository.getProcesses();

      // Update history lists
      _addToHistory(_cpuHistory, stats.cpuUsage);
      _addToHistory(_memoryHistory, stats.memoryUsage);
      _addToHistory(_networkDownloadHistory, stats.networkDownload);
      _addToHistory(_networkUploadHistory, stats.networkUpload);
      _addToHistory(_diskReadHistory, stats.diskRead);
      _addToHistory(_diskWriteHistory, stats.diskWrite);

      final newState = SystemStatsLoaded(
        stats: stats,
        processes: processes,
        cpuHistory: List<double>.from(_cpuHistory),
        memoryHistory: List<double>.from(_memoryHistory),
        networkDownloadHistory: List<double>.from(_networkDownloadHistory),
        networkUploadHistory: List<double>.from(_networkUploadHistory),
        diskReadHistory: List<double>.from(_diskReadHistory),
        diskWriteHistory: List<double>.from(_diskWriteHistory),
      );

      // إذا الحالة الحالية Loaded ولم تتغير البيانات -> لا تبعث emit
      if (state is SystemStatsLoaded) {
        final current = state as SystemStatsLoaded;
        if (current.stats == newState.stats &&
            _areProcessesEqual(current.processes, newState.processes)) {
          return; // لا تغيّر
        }
      }

      emit(newState);
    } catch (e) {
      emit(SystemStatsError(e.toString()));
    }
  }

  void _addToHistory(List<double> history, double value) {
    history.add(value);
    if (history.length > _maxHistoryLength) {
      history.removeAt(0);
    }
  }

  bool _areProcessesEqual(List<ProcessInfo> a, List<ProcessInfo> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
