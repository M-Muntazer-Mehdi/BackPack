class Result {
  bool responseStatus;
  String responseMessage;
  Object? responseData;

  Result(
      {required this.responseStatus,
      required this.responseMessage,
      this.responseData});
}
