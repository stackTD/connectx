import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Service for handling errors throughout the application
/// Provides consistent error logging, reporting, and user notification
class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();

  /// Log an error with optional context
  void logError(String message, {Object? error, StackTrace? stackTrace, String? context}) {
    final fullMessage = context != null ? '[$context] $message' : message;
    
    if (kDebugMode) {
      print('ERROR: $fullMessage');
      if (error != null) print('Error details: $error');
      if (stackTrace != null) print('Stack trace: $stackTrace');
    }
    
    // In production, you could send to crash reporting service
    // e.g., Crashlytics, Sentry, etc.
  }

  /// Log a warning message
  void logWarning(String message, {String? context}) {
    final fullMessage = context != null ? '[$context] $message' : message;
    
    if (kDebugMode) {
      print('WARNING: $fullMessage');
    }
  }

  /// Log an info message
  void logInfo(String message, {String? context}) {
    final fullMessage = context != null ? '[$context] $message' : message;
    
    if (kDebugMode) {
      print('INFO: $fullMessage');
    }
  }

  /// Show error dialog to user
  void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Show error snackbar
  void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show success snackbar
  void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Handle file operation errors
  void handleFileError(BuildContext context, String operation, Object error) {
    final message = 'Failed to $operation: ${error.toString()}';
    logError(message, error: error, context: 'FileOperation');
    showErrorSnackbar(context, AppConstants.errorFileOperation);
  }

  /// Handle connection errors
  void handleConnectionError(BuildContext context, String device, Object error) {
    final message = 'Failed to connect to $device: ${error.toString()}';
    logError(message, error: error, context: 'Connection');
    showErrorSnackbar(context, AppConstants.errorConnectionFailed);
  }

  /// Generic error handler for async operations
  T? handleAsyncError<T>(
    String operation, 
    T Function() action, {
    BuildContext? context,
    String? contextName,
  }) {
    try {
      return action();
    } catch (error, stackTrace) {
      final message = 'Error during $operation';
      logError(message, error: error, stackTrace: stackTrace, context: contextName);
      
      if (context != null) {
        showErrorSnackbar(context, 'Failed to $operation');
      }
      
      return null;
    }
  }

  /// Generic error handler for async Future operations
  Future<T?> handleAsyncFutureError<T>(
    String operation, 
    Future<T> Function() action, {
    BuildContext? context,
    String? contextName,
  }) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      final message = 'Error during $operation';
      logError(message, error: error, stackTrace: stackTrace, context: contextName);
      
      if (context != null) {
        showErrorSnackbar(context, 'Failed to $operation');
      }
      
      return null;
    }
  }
}