class ApiResult<T> {
  final T? data;
  final String? errorMessage;
  final int? statusCode;

  const ApiResult._({this.data, this.errorMessage, this.statusCode});

  const ApiResult.success(T data) : this._(data: data);

  const ApiResult.failure(String message, {int? statusCode})
    : this._(errorMessage: message, statusCode: statusCode);

  bool get isSuccess => data != null;
}

class ErrorsHandler {
  static String geminiStatusCodeMessage(
    int statusCode, {
    String? backendStatus,
  }) {
    if (backendStatus == 'FAILED_PRECONDITION') {
      return 'Gemini API is not available for this account or region. Please check billing or API access.';
    }

    switch (statusCode) {
      case 400:
        return 'Gemini could not understand this request. Please try again.';
      case 401:
        return 'Your Gemini API key is missing or invalid.';
      case 402:
        return 'Gemini billing or quota is not available for this account.';
      case 403:
        return 'Your Gemini API key is invalid or does not have permission.';
      case 404:
        return 'The selected Gemini model was not found.';
      case 429:
        return 'Gemini usage limit reached. Please wait and try again later.';
      case 499:
        return 'The request was cancelled before Gemini could respond.';
      case 500:
        return 'Gemini had an internal error. Please try again shortly.';
      case 503:
        return 'Gemini is temporarily busy or unavailable. Please try again later.';
      case 504:
        return 'Gemini took too long to respond. Try a shorter answer or prompt.';
      default:
        return 'Gemini request failed. Please try again.';
    }
  }

  static String geminiParsingMessage() {
    return 'Gemini returned an unexpected response. Please try again.';
  }

  static String geminiTimeoutMessage() {
    return 'Gemini took too long to respond. Please try again.';
  }

  static String geminiNetworkMessage() {
    return 'Could not connect to Gemini. Please check your internet connection.';
  }

  static String geminiApiKeyMessage() {
    return 'Please enter a valid Gemini API key before starting the interview.';
  }

  static String geminiEmptyResponseMessage() {
    return 'Gemini did not return a response. Please try again.';
  }
}
