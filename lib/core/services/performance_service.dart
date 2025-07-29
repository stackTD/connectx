import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'error_service.dart';

/// Service for performance monitoring and optimization
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final ErrorService _errorService = ErrorService();
  final Map<String, DateTime> _operationStartTimes = {};
  final Queue<PerformanceMetric> _metrics = Queue();
  static const int _maxMetricsCount = 100;

  /// Track the start of an operation
  void startOperation(String operationName) {
    _operationStartTimes[operationName] = DateTime.now();
  }

  /// Track the end of an operation and log the duration
  void endOperation(String operationName) {
    final startTime = _operationStartTimes.remove(operationName);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _addMetric(PerformanceMetric(
        operationName: operationName,
        duration: duration,
        timestamp: DateTime.now(),
      ));
      
      if (kDebugMode) {
        _errorService.logInfo(
          'Operation "$operationName" took ${duration.inMilliseconds}ms',
          context: 'Performance',
        );
      }
    }
  }

  /// Add a performance metric
  void _addMetric(PerformanceMetric metric) {
    _metrics.add(metric);
    
    // Keep only the last N metrics to prevent memory leaks
    while (_metrics.length > _maxMetricsCount) {
      _metrics.removeFirst();
    }
  }

  /// Get average duration for an operation
  Duration? getAverageDuration(String operationName) {
    final relevantMetrics = _metrics
        .where((metric) => metric.operationName == operationName)
        .toList();
    
    if (relevantMetrics.isEmpty) return null;
    
    final totalMs = relevantMetrics
        .map((metric) => metric.duration.inMilliseconds)
        .reduce((a, b) => a + b);
    
    return Duration(milliseconds: totalMs ~/ relevantMetrics.length);
  }

  /// Get performance report
  Map<String, dynamic> getPerformanceReport() {
    final report = <String, dynamic>{};
    final operationNames = _metrics
        .map((metric) => metric.operationName)
        .toSet();
    
    for (final operationName in operationNames) {
      final metrics = _metrics
          .where((metric) => metric.operationName == operationName)
          .toList();
      
      if (metrics.isNotEmpty) {
        final durations = metrics.map((m) => m.duration.inMilliseconds).toList();
        durations.sort();
        
        report[operationName] = {
          'count': metrics.length,
          'averageMs': durations.reduce((a, b) => a + b) / durations.length,
          'minMs': durations.first,
          'maxMs': durations.last,
          'medianMs': durations[durations.length ~/ 2],
        };
      }
    }
    
    return report;
  }

  /// Time a function execution
  T timeOperation<T>(String operationName, T Function() operation) {
    startOperation(operationName);
    try {
      return operation();
    } finally {
      endOperation(operationName);
    }
  }

  /// Time an async function execution
  Future<T> timeAsyncOperation<T>(String operationName, Future<T> Function() operation) async {
    startOperation(operationName);
    try {
      return await operation();
    } finally {
      endOperation(operationName);
    }
  }

  /// Check if an operation is taking too long
  bool isOperationSlow(String operationName, Duration threshold) {
    final avgDuration = getAverageDuration(operationName);
    return avgDuration != null && avgDuration > threshold;
  }

  /// Clear all metrics
  void clearMetrics() {
    _metrics.clear();
    _operationStartTimes.clear();
  }

  /// Get recent slow operations
  List<PerformanceMetric> getSlowOperations(Duration threshold) {
    return _metrics
        .where((metric) => metric.duration > threshold)
        .toList()
      ..sort((a, b) => b.duration.compareTo(a.duration));
  }
}

/// Performance metric data class
class PerformanceMetric {
  final String operationName;
  final Duration duration;
  final DateTime timestamp;

  PerformanceMetric({
    required this.operationName,
    required this.duration,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'PerformanceMetric(operation: $operationName, duration: ${duration.inMilliseconds}ms, timestamp: $timestamp)';
  }
}

/// Mixin for adding performance tracking to widgets
mixin PerformanceTrackingMixin {
  final PerformanceService _performanceService = PerformanceService();

  /// Track widget build performance
  void trackBuildPerformance(String widgetName, VoidCallback buildFunction) {
    _performanceService.timeOperation('${widgetName}_build', buildFunction);
  }

  /// Track async operation performance
  Future<T> trackAsyncPerformance<T>(String operationName, Future<T> Function() operation) {
    return _performanceService.timeAsyncOperation(operationName, operation);
  }
}

/// Widget for displaying performance information in debug mode
class PerformanceDebugWidget extends StatelessWidget {
  final PerformanceService _performanceService = PerformanceService();

  PerformanceDebugWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Performance Metrics',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._buildMetricsWidgets(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMetricsWidgets() {
    final report = _performanceService.getPerformanceReport();
    
    if (report.isEmpty) {
      return [const Text('No performance data available')];
    }

    return report.entries.map((entry) {
      final metrics = entry.value as Map<String, dynamic>;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          '${entry.key}: avg ${metrics['averageMs']?.toStringAsFixed(1)}ms '
          '(${metrics['count']} calls)',
          style: const TextStyle(fontSize: 12),
        ),
      );
    }).toList();
  }
}