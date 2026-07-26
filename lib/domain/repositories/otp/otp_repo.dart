abstract class OtpRepository {
  Future<bool> sendOtp({required String email});
  bool verifyOtp({required String inputOtp, required String correctOtp});
  String generateOtp();
}
