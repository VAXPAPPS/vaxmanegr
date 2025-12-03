class SystemStats {
  final double cpuUsage;
  final double memoryUsage;
  final double totalMemory;
  final double networkUpload;
  final double networkDownload;
  final double diskRead;
  final double diskWrite;

  SystemStats({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.totalMemory,
    required this.networkUpload,
    required this.networkDownload,
    required this.diskRead,
    required this.diskWrite,
  });
}

class ProcessInfo {
  final String name;
  final int pid;
  final double cpuUsage;
  final double memoryUsage;
  final double rssMb; // Total Resident Set Size (for comparison)
  final double privateDirtyMb; // Real used memory by the app (Variables/Heap)
  final double privateCleanMb; // Read-only mapped files (Assets/Engine/Cache)

  ProcessInfo({
    required this.name,
    required this.pid,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.rssMb,
    required this.privateDirtyMb,
    required this.privateCleanMb,
  });
}
