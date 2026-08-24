package com.supermarket.supermarket.service;

public interface EmailService {
    void sendOtpEmail(String to, String otp);
}