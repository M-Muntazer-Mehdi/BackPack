import 'dart:async';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

enum AudioPlayerState {
  idle,
  loading,
  playing,
  paused,
  stopped,
  error,
}

class AudioPlayerController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  AudioPlayerState playerState = AudioPlayerState.idle;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  double playbackSpeed = 1.0;
  String? currentlyPlayingUrl;
  
  // Stream subscriptions
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _stateSubscription;
  
  @override
  void onInit() {
    super.onInit();
    _initializePlayer();
  }
  
  @override
  void onClose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _stateSubscription?.cancel();
    _audioPlayer.dispose();
    super.onClose();
  }
  
  void _initializePlayer() {
    // Listen to position changes
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      currentPosition = position;
      update();
    });
    
    // Listen to duration changes
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      totalDuration = duration;
      update();
    });
    
    // Listen to player state changes
    _stateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      switch (state) {
        case PlayerState.playing:
          if (playerState != AudioPlayerState.playing) {
            playerState = AudioPlayerState.playing;
            update();
          }
          break;
        case PlayerState.paused:
          if (playerState != AudioPlayerState.paused) {
            playerState = AudioPlayerState.paused;
            update();
          }
          break;
        case PlayerState.stopped:
        case PlayerState.completed:
          playerState = AudioPlayerState.stopped;
          currentPosition = Duration.zero;
          update();
          break;
        case PlayerState.disposed:
          playerState = AudioPlayerState.idle;
          update();
          break;
      }
    });
  }
  
  /// Play audio from URL
  Future<void> play(String url) async {
    try {
      log('🎵 Attempting to play: $url');
      
      // If already playing this URL, just resume
      if (currentlyPlayingUrl == url && playerState == AudioPlayerState.paused) {
        log('Resuming paused audio');
        await resume();
        return;
      }
      
      // Prevent multiple clicks during loading
      if (playerState == AudioPlayerState.loading && currentlyPlayingUrl == url) {
        log('Already loading this audio, ignoring duplicate request');
        return;
      }
      
      // ALWAYS stop any current playback first (clean slate)
      if (currentlyPlayingUrl != null && currentlyPlayingUrl != url) {
        log('Stopping current playback: $currentlyPlayingUrl');
        try {
          await _audioPlayer.stop();
          await Future.delayed(const Duration(milliseconds: 200)); // Increased delay
        } catch (e) {
          log('Error stopping previous audio: $e');
        }
      }
      
      // Reset state
      playerState = AudioPlayerState.loading;
      currentlyPlayingUrl = url;
      currentPosition = Duration.zero;
      totalDuration = Duration.zero;
      update();
      
      log('Starting playback...');
      
      // Set source and play with timeout
      await _audioPlayer.play(UrlSource(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Audio loading timeout - check your internet connection');
        },
      );
      
      log('✅ Audio playing successfully: $url');
    } catch (e) {
      log('❌ Error playing audio: $e');
      // Reset to idle instead of staying in error
      playerState = AudioPlayerState.error;
      final errorUrl = currentlyPlayingUrl;
      
      // Update UI to show error briefly
      update();
      
      // Auto-recover after 1 second
      await Future.delayed(const Duration(seconds: 1));
      
      // Only reset if we're still on the same errored URL
      if (currentlyPlayingUrl == errorUrl) {
        playerState = AudioPlayerState.idle;
        currentlyPlayingUrl = null;
        currentPosition = Duration.zero;
        totalDuration = Duration.zero;
        update();
      }
      
      // Try to recover by stopping
      try {
        await _audioPlayer.stop();
      } catch (_) {}
    }
  }
  
  /// Pause playback
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      playerState = AudioPlayerState.paused;
      update();
      log('Audio paused');
    } catch (e) {
      log('Error pausing audio: $e');
    }
  }
  
  /// Resume playback
  Future<void> resume() async {
    try {
      await _audioPlayer.resume();
      playerState = AudioPlayerState.playing;
      update();
      log('Audio resumed');
    } catch (e) {
      log('Error resuming audio: $e');
    }
  }
  
  /// Stop playback
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      playerState = AudioPlayerState.stopped;
      currentPosition = Duration.zero;
      totalDuration = Duration.zero;
      currentlyPlayingUrl = null;
      update();
      log('Audio stopped');
    } catch (e) {
      log('Error stopping audio: $e');
      // Force reset even if stop fails
      playerState = AudioPlayerState.stopped;
      currentPosition = Duration.zero;
      totalDuration = Duration.zero;
      currentlyPlayingUrl = null;
      update();
    }
  }
  
  /// Force reset the player (useful for recovery)
  Future<void> forceReset() async {
    try {
      log('Force resetting audio player');
      await _audioPlayer.stop();
      await _audioPlayer.release();
    } catch (e) {
      log('Error during force reset: $e');
    } finally {
      playerState = AudioPlayerState.idle;
      currentPosition = Duration.zero;
      totalDuration = Duration.zero;
      currentlyPlayingUrl = null;
      playbackSpeed = 1.0;
      update();
    }
  }
  
  /// Seek to position
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      log('Seeked to: ${position.inSeconds}s');
    } catch (e) {
      log('Error seeking: $e');
    }
  }
  
  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    try {
      await _audioPlayer.setPlaybackRate(speed);
      playbackSpeed = speed;
      update();
      log('Playback speed set to: ${speed}x');
    } catch (e) {
      log('Error setting playback speed: $e');
    }
  }
  
  /// Toggle play/pause
  Future<void> togglePlayPause(String url) async {
    log('Toggle play/pause for: $url, current state: $playerState, currentUrl: $currentlyPlayingUrl');
    
    try {
      // Ignore clicks while loading (prevent double-clicks)
      if (playerState == AudioPlayerState.loading) {
        log('Currently loading, ignoring toggle request');
        return;
      }
      
      if (currentlyPlayingUrl == url) {
        if (playerState == AudioPlayerState.playing) {
          log('Pausing current audio');
          await pause();
        } else if (playerState == AudioPlayerState.paused) {
          log('Resuming paused audio');
          await resume();
        } else if (playerState == AudioPlayerState.stopped) {
          // Stopped - play from beginning
          log('Restarting stopped audio');
          await play(url);
        } else {
          // Idle or error state - play fresh
          log('State is $playerState, playing fresh');
          await play(url);
        }
      } else {
        // Different URL or no current URL - play new
        log('Playing new audio (different from current)');
        await play(url);
      }
    } catch (e) {
      log('❌ Error in togglePlayPause: $e');
      // Reset and try to recover
      playerState = AudioPlayerState.idle;
      currentlyPlayingUrl = null;
      currentPosition = Duration.zero;
      totalDuration = Duration.zero;
      update();
    }
  }
  
  /// Check if currently playing this URL
  bool isPlaying(String url) {
    return currentlyPlayingUrl == url && 
           playerState == AudioPlayerState.playing;
  }
  
  /// Check if currently paused on this URL
  bool isPaused(String url) {
    return currentlyPlayingUrl == url && 
           playerState == AudioPlayerState.paused;
  }
  
  /// Check if loading this URL
  bool isLoading(String url) {
    return currentlyPlayingUrl == url && 
           playerState == AudioPlayerState.loading;
  }
  
  /// Check if in error state for this URL
  bool isError(String url) {
    return currentlyPlayingUrl == url && 
           playerState == AudioPlayerState.error;
  }
  
  /// Get progress (0.0 to 1.0)
  double getProgress(String url) {
    if (currentlyPlayingUrl != url || totalDuration.inMilliseconds == 0) {
      return 0.0;
    }
    return currentPosition.inMilliseconds / totalDuration.inMilliseconds;
  }
  
  /// Get current position for specific URL
  Duration getCurrentPosition(String url) {
    if (currentlyPlayingUrl == url) {
      return currentPosition;
    }
    return Duration.zero;
  }
  
  /// Get total duration for specific URL
  Duration getTotalDuration(String url) {
    if (currentlyPlayingUrl == url) {
      return totalDuration;
    }
    return Duration.zero;
  }
}


