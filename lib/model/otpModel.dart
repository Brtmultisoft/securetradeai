// OTP Response Models for SecureTradeAI

class OtpSendResponse {
  final String status;
  final String message;
  final String? requestId;

  OtpSendResponse({
    required this.status,
    required this.message,
    this.requestId,
  });

  factory OtpSendResponse.fromJson(Map<String, dynamic> json) {
    return OtpSendResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      requestId: json['requestId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'requestId': requestId,
    };
  }

  bool get isSuccess => status.toLowerCase() == 'success';
}

class OtpVerifyResponse {
  final String status;
  final String message;
  final OtpVerifyData? data;

  OtpVerifyResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory OtpVerifyResponse.fromJson(Map<String, dynamic> json) {
    return OtpVerifyResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] != null ? OtpVerifyData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }

  bool get isSuccess => status.toLowerCase() == 'success' && 
                       data != null && 
                       data!.status.toLowerCase() == 'success';
}

class OtpVerifyData {
  final String status;
  final String message;

  OtpVerifyData({
    required this.status,
    required this.message,
  });

  factory OtpVerifyData.fromJson(Map<String, dynamic> json) {
    return OtpVerifyData(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
    };
  }
}

// Request Models
class OtpSendRequest {
  final String email;
  final String? type;

  OtpSendRequest({
    required this.email,
    this.type,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
    };
    if (type != null) {
      data['type'] = type;
    }
    return data;
  }
}

class OtpVerifyRequest {
  final String email;
  final String otp;
  final String requestId;

  OtpVerifyRequest({
    required this.email,
    required this.otp,
    required this.requestId,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
      'requestId': requestId,
    };
  }
}
