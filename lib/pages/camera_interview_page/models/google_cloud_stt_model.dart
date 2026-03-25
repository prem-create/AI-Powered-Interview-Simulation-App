class GoogleCloudSttPost {
    List<Result> results;
    String totalBilledTime;
    String requestId;

    GoogleCloudSttPost({
        required this.results,
        required this.totalBilledTime,
        required this.requestId,
    });

}

class Result {
    List<Alternative> alternatives;
    String resultEndTime;
    String languageCode;

    Result({
        required this.alternatives,
        required this.resultEndTime,
        required this.languageCode,
    });

}

class Alternative {
    String transcript;
    double confidence;

    Alternative({
        required this.transcript,
        required this.confidence,
    });

}
