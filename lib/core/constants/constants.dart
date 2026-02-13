// ============================================================================
// CONSTANTS - Global Application Constants
// ============================================================================
// Stores global constants used throughout the application
// 
// CURRENT CONSTANTS:
// - apiKey: Gemini AI API key for authentication
// 
// USAGE:
// - Import this file wherever API key is needed
// - Set apiKey value before making API calls
// - Used by both camera interview and talk to AI features
// 
// SECURITY NOTE:
// - API key should be stored securely (environment variables, secure storage)
// - Never commit actual API keys to version control
// - Consider using flutter_dotenv or similar for production
// 
// TODO: Add more constants:
// - API base URLs
// - Timeout durations
// - Default configuration values
// - Theme colors
// - App version info
// ============================================================================

/// Gemini AI API key - must be set before using AI features
/// Currently marked as 'late' - will be initialized at runtime
late String apiKey;
