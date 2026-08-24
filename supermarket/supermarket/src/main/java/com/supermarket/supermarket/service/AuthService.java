package com.supermarket.supermarket.service;

import com.supermarket.supermarket.dto.request.LoginRequest;
import com.supermarket.supermarket.dto.response.LoginResponse;

public interface AuthService {
    LoginResponse login(LoginRequest request);
    void sendOtpForPasswordReset(String email);
    boolean verifyOtp(String otp);
    void resetPassword(String otp, String newPassword);
}

