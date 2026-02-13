// ============================================================================
// HOME STATES - UI States for Home Page
// ============================================================================
// Defines all possible states the home page can be in
// UI rebuilds based on these states
// 
// STATE TYPES:
// 1. Regular States - Trigger UI rebuild (HomeInitial, ApiKeyState)
// 2. Action States - Trigger one-time actions like navigation
// ============================================================================

part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

/// Initial state when home page loads
/// Shows the main menu with three interview options
final class HomeInitial extends HomeState {}

/// Base class for action states
/// Action states trigger navigation without rebuilding the entire UI
abstract class HomeActionState extends HomeState {}

/// Action State: Navigate to Camera Interview page
/// Triggers when user wants to start AI interview with voice
final class CameraInterviewActionState extends HomeActionState {}

/// Action State: Navigate to Talk to AI page
/// Triggers when user wants to start text-based chat interview
final class StartTalkToAiActionState extends HomeActionState {}

/// State: API key validation in progress
/// Shows loading or validation UI while checking Gemini API configuration
final class ApiKeyState extends HomeState {}

/// Action State: Navigate to MCQ Quiz page
/// Triggers when user wants to take multiple choice test
final class McqActionState extends HomeActionState {}
