import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:interview_app/core/constants/constants.dart';

class RemoteConfigService {
  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _remoteConfig;

  bool get hasApiKeys =>
      geminiApiKey.trim().isNotEmpty && googleCloudSttApiKey.trim().isNotEmpty;

  Future<void> loadApiKeys() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(seconds: 0),
      ),
    );

    await _remoteConfig.setDefaults({'gemini_api_key': '', 'stt_api_key': ''});

    try {
      await _remoteConfig.fetchAndActivate();
    } on FirebaseException catch (error) {
      _applyCachedApiKeys();
      if (hasApiKeys) {
        log(
          'Remote Config fetch failed, using cached API keys: ${error.message}',
        );
        return;
      }
      throw RemoteConfigLoadException.offline();
    } catch (error) {
      _applyCachedApiKeys();
      if (hasApiKeys) {
        log('Remote Config fetch failed, using cached API keys: $error');
        return;
      }
      throw RemoteConfigLoadException.offline();
    }

    _applyCachedApiKeys();

    if (!hasApiKeys) {
      throw RemoteConfigLoadException.missingKeys();
    }
  }

  void _applyCachedApiKeys() {
    geminiApiKey = _remoteConfig.getString('gemini_api_key');
    googleCloudSttApiKey = _remoteConfig.getString('stt_api_key');
  }
}

class RemoteConfigLoadException implements Exception {
  const RemoteConfigLoadException(this.message);

  factory RemoteConfigLoadException.offline() {
    return const RemoteConfigLoadException(
      'Internet is off. Please turn it on and try again to load the app configuration.',
    );
  }

  factory RemoteConfigLoadException.missingKeys() {
    return const RemoteConfigLoadException(
      'App configuration is not available. Please try again.',
    );
  }

  final String message;
}
