package com.supermarket.supermarket.service.impl;

import com.supermarket.supermarket.dto.request.LoginRequest;
import com.supermarket.supermarket.dto.response.LoginResponse;
import com.supermarket.supermarket.entity.PasswordResetToken;
import com.supermarket.supermarket.entity.Role;
import com.supermarket.supermarket.entity.User;
import com.supermarket.supermarket.repository.PasswordResetTokenRepository;
import com.supermarket.supermarket.repository.UserRepository;
import com.supermarket.supermarket.service.AuthService;
import com.supermarket.supermarket.service.EmailService;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.Random;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final EmailService emailService;

    @Override
    public LoginResponse login(LoginRequest request) {
        String identifier = request.getEmail().trim();
        List<User> users = userRepository.findByUsernameIgnoreCaseOrEmailIgnoreCase(identifier, identifier);

        if (users.isEmpty()) {
            return LoginResponse.builder()
                .success(false)
                .message("Invalid email/username or password")
                .build();
        }

        // Try to find a user where the password matches
        for (User user : users) {
            LoginResponse response = validatePasswordAndBuildResponse(user, request.getPassword());
            if (response.isSuccess()) {
                return response;
            }
        }

        return LoginResponse.builder()
            .success(false)
            .message("Invalid email/username or password")
            .build();
    }

    private LoginResponse validatePasswordAndBuildResponse(User user, String rawPassword) {
        if (user.getStatus() != null && "deactive".equalsIgnoreCase(user.getStatus())) {
            return LoginResponse.builder()
                .success(false)
                .message("Account is deactivated")
                .build();
        }

        if (!isPasswordMatched(rawPassword, user.getPasswordHash())) {
            return LoginResponse.builder()
                .success(false)
                .message("Invalid email/username or password")
                .build();
        }

        user.setLastLogin(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);

        String roleName = getRoleName(user.getRole());
        return LoginResponse.builder()
            .success(true)
            .message("Login successful")
            .userId(user.getId())
            .roleId(user.getRole() == null ? null : user.getRole().getId())
            .username(user.getUsername())
            .fullName(user.getFullname())
            .role(roleName)
            .redirectTo(resolveRouteByRole(roleName))
            .build();
    }

    private boolean isPasswordMatched(String rawPassword, String storedPasswordHash) {
        if (storedPasswordHash == null || storedPasswordHash.isBlank()) {
            return false;
        }

        // Try BCrypt matching first. Any valid BCrypt hash ($2a$, $2b$, $2y$, etc.) 
        // will be handled correctly by the encoder.
        try {
            return passwordEncoder.matches(rawPassword, storedPasswordHash);
        } catch (Exception e) {
            // If it's not a valid BCrypt hash, fallback to plain text comparison 
            // to support raw seed/demo data.
            return rawPassword.equals(storedPasswordHash);
        }
    }

    private String getRoleName(Role role) {
        return role == null || role.getName() == null ? "UNKNOWN" : role.getName();
    }

    private String resolveRouteByRole(String roleName) {
        String normalized = roleName.toLowerCase();
        if (normalized.contains("admin")) {
            return "/admin/dashboard";
        }
        if (normalized.contains("manager")) {
            return "/manager/dashboard";
        }
        if (normalized.contains("cashier")) {
            return "/cashier/open-shift";
        }
        return "/home";
    }

    @Override
    @Transactional
    public void sendOtpForPasswordReset(String email) {
        String trimmedEmail = email.trim();
        List<User> users = userRepository.findByUsernameIgnoreCaseOrEmailIgnoreCase(trimmedEmail, trimmedEmail);

        if (users.isEmpty()) {
            throw new RuntimeException("Email address not registered.");
        }

        // Delete expired tokens
        passwordResetTokenRepository.deleteExpiredTokens(LocalDateTime.now());

        // Generate OTP
        String otp = generateOtp();

        // Save token - link to the first user if any exist
        PasswordResetToken token = PasswordResetToken.builder()
            .user(users.get(0))
            .email(trimmedEmail)
            .otp(otp)
            .token(java.util.UUID.randomUUID().toString())
            .expiresAt(LocalDateTime.now().plusMinutes(10))
            .build();
        passwordResetTokenRepository.save(token);

        // Send email
        emailService.sendOtpEmail(trimmedEmail, otp);
    }

    @Override
    public boolean verifyOtp(String otp) {
        Optional<PasswordResetToken> tokenOpt = passwordResetTokenRepository.findByOtpAndExpiresAtAfter(otp, LocalDateTime.now());
        return tokenOpt.isPresent();
    }

    @Override
    @Transactional
    public void resetPassword(String otp, String newPassword) {
        PasswordResetToken token = passwordResetTokenRepository.findByOtpAndExpiresAtAfter(otp, LocalDateTime.now())
            .orElseThrow(() -> new RuntimeException("Invalid or expired OTP"));

        String resetEmail = token.getEmail();
        List<User> usersToUpdate = userRepository.findByUsernameIgnoreCaseOrEmailIgnoreCase(resetEmail, resetEmail);

        if (usersToUpdate.isEmpty()) {
            throw new RuntimeException("No users associated with this OTP. If you entered a non-existent email, you cannot reset a password for it.");
        }

        String hashedPw = passwordEncoder.encode(newPassword);
        for (User user : usersToUpdate) {
            user.setPasswordHash(hashedPw);
            user.setUpdatedAt(LocalDateTime.now());
            userRepository.save(user);
        }

        // Consume token
        passwordResetTokenRepository.delete(token);
    }

    private String generateOtp() {
        Random random = new Random();
        int otp = 100000 + random.nextInt(900000);
        return String.valueOf(otp);
    }
}
