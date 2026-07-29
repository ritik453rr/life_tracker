/// Standard API response model used across network layer.
class ResponseModel {
  bool status;
  String message;
  dynamic data;

  ResponseModel({
    this.status = false,
    this.message = "",
    this.data = "",
  });
}
