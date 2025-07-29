import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'error_service.dart';

/// Service for handling file operations throughout the application
/// Provides consistent file I/O with proper error handling
class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();

  final ErrorService _errorService = ErrorService();

  /// Get the application documents directory
  Future<Directory> getApplicationDirectory() async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (error) {
      _errorService.logError('Failed to get application directory', error: error);
      // Fallback to current directory
      return Directory.current;
    }
  }

  /// Save data to a JSON file
  Future<bool> saveJsonFile(String fileName, Map<String, dynamic> data) async {
    try {
      final directory = await getApplicationDirectory();
      final file = File('${directory.path}/$fileName');
      final jsonString = jsonEncode(data);
      await file.writeAsString(jsonString);
      
      _errorService.logInfo('Successfully saved file: $fileName');
      return true;
    } catch (error) {
      _errorService.logError('Failed to save JSON file: $fileName', error: error);
      return false;
    }
  }

  /// Load data from a JSON file
  Future<Map<String, dynamic>?> loadJsonFile(String fileName) async {
    try {
      final directory = await getApplicationDirectory();
      final file = File('${directory.path}/$fileName');
      
      if (!await file.exists()) {
        _errorService.logWarning('File does not exist: $fileName');
        return null;
      }
      
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      _errorService.logInfo('Successfully loaded file: $fileName');
      return data;
    } catch (error) {
      _errorService.logError('Failed to load JSON file: $fileName', error: error);
      return null;
    }
  }

  /// Save project data as .connectx file
  Future<bool> saveConnectXProject(String projectName, Map<String, dynamic> projectData) async {
    try {
      // Add metadata to project
      projectData['metadata'] = {
        'version': '1.0',
        'created': DateTime.now().toIso8601String(),
        'application': 'SCADA ConnectX',
      };
      
      final fileName = projectName.endsWith(AppConstants.connectxFileExtension) 
          ? projectName 
          : '$projectName${AppConstants.connectxFileExtension}';
      
      return await saveJsonFile(fileName, projectData);
    } catch (error) {
      _errorService.logError('Failed to save ConnectX project: $projectName', error: error);
      return false;
    }
  }

  /// Load project data from .connectx file
  Future<Map<String, dynamic>?> loadConnectXProject(String projectName) async {
    try {
      final fileName = projectName.endsWith(AppConstants.connectxFileExtension) 
          ? projectName 
          : '$projectName${AppConstants.connectxFileExtension}';
      
      final data = await loadJsonFile(fileName);
      
      if (data != null) {
        // Validate project data
        if (_validateProjectData(data)) {
          return data;
        } else {
          _errorService.logError('Invalid project data format in: $fileName');
          return null;
        }
      }
      
      return null;
    } catch (error) {
      _errorService.logError('Failed to load ConnectX project: $projectName', error: error);
      return null;
    }
  }

  /// Validate project data structure
  bool _validateProjectData(Map<String, dynamic> data) {
    // Basic validation - can be extended as needed
    return data.containsKey('metadata') || data.containsKey('canvases') || data.containsKey('items');
  }

  /// Get list of available projects
  Future<List<String>> getAvailableProjects() async {
    try {
      final directory = await getApplicationDirectory();
      final files = directory.listSync()
          .where((file) => file.path.endsWith(AppConstants.connectxFileExtension))
          .map((file) => file.path.split('/').last)
          .toList();
      
      return files;
    } catch (error) {
      _errorService.logError('Failed to get available projects', error: error);
      return [];
    }
  }

  /// Create backup of a file
  Future<bool> createBackup(String fileName) async {
    try {
      final directory = await getApplicationDirectory();
      final originalFile = File('${directory.path}/$fileName');
      
      if (!await originalFile.exists()) {
        _errorService.logWarning('Cannot backup non-existent file: $fileName');
        return false;
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFileName = '${fileName}.backup.$timestamp';
      final backupFile = File('${directory.path}/$backupFileName');
      
      await originalFile.copy(backupFile.path);
      _errorService.logInfo('Created backup: $backupFileName');
      return true;
    } catch (error) {
      _errorService.logError('Failed to create backup for: $fileName', error: error);
      return false;
    }
  }

  /// Save configuration to SharedPreferences
  Future<bool> saveConfig(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
      return true;
    } catch (error) {
      _errorService.logError('Failed to save config: $key', error: error);
      return false;
    }
  }

  /// Load configuration from SharedPreferences
  Future<String?> loadConfig(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (error) {
      _errorService.logError('Failed to load config: $key', error: error);
      return null;
    }
  }

  /// Export project data to a specific path
  Future<bool> exportProject(String projectName, String exportPath) async {
    try {
      final projectData = await loadConnectXProject(projectName);
      if (projectData == null) {
        _errorService.logError('Cannot export non-existent project: $projectName');
        return false;
      }
      
      final exportFile = File(exportPath);
      final jsonString = jsonEncode(projectData);
      await exportFile.writeAsString(jsonString);
      
      _errorService.logInfo('Exported project $projectName to $exportPath');
      return true;
    } catch (error) {
      _errorService.logError('Failed to export project: $projectName', error: error);
      return false;
    }
  }

  /// Import project data from a specific path
  Future<bool> importProject(String importPath, String projectName) async {
    try {
      final importFile = File(importPath);
      if (!await importFile.exists()) {
        _errorService.logError('Import file does not exist: $importPath');
        return false;
      }
      
      final jsonString = await importFile.readAsString();
      final projectData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      if (!_validateProjectData(projectData)) {
        _errorService.logError('Invalid project data in import file: $importPath');
        return false;
      }
      
      return await saveConnectXProject(projectName, projectData);
    } catch (error) {
      _errorService.logError('Failed to import project from: $importPath', error: error);
      return false;
    }
  }
}