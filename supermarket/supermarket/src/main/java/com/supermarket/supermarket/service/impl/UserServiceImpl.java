package com.supermarket.supermarket.service.impl;

import com.supermarket.supermarket.dto.request.CreateUserRequest;
import com.supermarket.supermarket.dto.request.UpdateProfileRequest;
import com.supermarket.supermarket.dto.request.UpdateUserRequest;
import com.supermarket.supermarket.dto.request.ChangePasswordRequest;
import com.supermarket.supermarket.dto.response.RoleOptionResponse;
import com.supermarket.supermarket.dto.response.UserDetailResponse;
import com.supermarket.supermarket.dto.response.UserScheduleItemResponse;
import com.supermarket.supermarket.dto.response.UserListItemResponse;
import com.supermarket.supermarket.entity.Role;
import com.supermarket.supermarket.entity.Shift;
import com.supermarket.supermarket.entity.User;
import com.supermarket.supermarket.repository.RoleRepository;
import com.supermarket.supermarket.repository.ShiftRepository;
import com.supermarket.supermarket.repository.UserRepository;
import com.supermarket.supermarket.service.UserService;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final ShiftRepository shiftRepository;
    private final PasswordEncoder passwordEncoder;
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm");
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Override
    public List<UserListItemResponse> getAllUsers() {
        return userRepository.findAllByOrderByIdAsc()
            .stream()
            .map(this::toUserListItemResponse)
            .toList();
    }

    @Override
    public UserListItemResponse createUser(CreateUserRequest request) {
        String username = request.getUsername().trim();
        String email = request.getEmail().trim();

        if (userRepository.existsByUsernameIgnoreCase(username)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Username already exists");
        }
        if (userRepository.existsByEmailIgnoreCase(email)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Email already exists");
        }

        Role role = resolveRole(request.getUserRole());
        LocalDateTime now = LocalDateTime.now();

        User user = User.builder()
            .fullname(request.getFullname().trim())
            .username(username)
            .email(email)
            .passwordHash(passwordEncoder.encode(request.getPassword()))
            .idCard(normalizeOptionalText(request.getIdCard()))
            .status("active")
            .role(role)
            .createdAt(now)
            .updatedAt(now)
            .build();

        User created = userRepository.save(user);
        return toUserListItemResponse(created);
    }

    @Override
    public List<RoleOptionResponse> getAllRoles() {
        return roleRepository.findAll()
            .stream()
            .map(role -> RoleOptionResponse.builder()
                .id(role.getId())
                .name(role.getName())
                .build())
            .toList();
    }

    @Override
    public UserDetailResponse getUserDetail(Integer userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        return toUserDetailResponse(user);
    }

    @Override
    public UserListItemResponse updateUser(Integer userId, UpdateUserRequest request) {
        User existing = userRepository.findById(userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        String username = request.getUsername().trim();
        String email = request.getEmail().trim();
        String existingUsername = existing.getUsername() == null ? "" : existing.getUsername();
        String existingEmail = existing.getEmail() == null ? "" : existing.getEmail();

        if (userRepository.existsByUsernameIgnoreCase(username)
            && !existingUsername.equalsIgnoreCase(username)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Username already exists");
        }
        if (userRepository.existsByEmailIgnoreCase(email)
            && !existingEmail.equalsIgnoreCase(email)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Email already exists");
        }

        Role role = resolveRole(request.getUserRole());
        existing.setFullname(request.getFullname().trim());
        existing.setUsername(username);
        existing.setEmail(email);
        existing.setIdCard(normalizeOptionalText(request.getIdCard()));
        existing.setRole(role);
        existing.setUpdatedAt(LocalDateTime.now());

        String newPassword = normalizeOptionalText(request.getPassword());
        if (newPassword != null) {
            existing.setPasswordHash(passwordEncoder.encode(newPassword));
        }

        User updated = userRepository.save(existing);
        return toUserListItemResponse(updated);
    }

    @Override
    public UserListItemResponse updateUserStatus(Integer userId, String status) {
        User existing = userRepository.findById(userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        String normalized = status == null ? "" : status.trim().toLowerCase();
        if (!"active".equals(normalized) && !"deactive".equals(normalized)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Status must be active or deactive");
        }

        existing.setStatus(normalized);
        existing.setUpdatedAt(LocalDateTime.now());
        User updated = userRepository.save(existing);
        return toUserListItemResponse(updated);
    }

    @Override
    public UserDetailResponse updateProfile(Integer userId, UpdateProfileRequest request) {
        User existing = userRepository.findById(userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        String email = request.getEmail().trim();
        String existingEmail = existing.getEmail() == null ? "" : existing.getEmail();
        if (userRepository.existsByEmailIgnoreCase(email) && !existingEmail.equalsIgnoreCase(email)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Email already exists");
        }

        existing.setFullname(request.getFullname().trim());
        existing.setEmail(email);
        existing.setIdCard(normalizeOptionalText(request.getIdCard()));
        existing.setPhone(normalizeOptionalText(request.getPhone()));
        existing.setAddress(normalizeOptionalText(request.getAddress()));
        existing.setDob(parseDob(request.getDob()));
        existing.setUpdatedAt(LocalDateTime.now());

        User updated = userRepository.save(existing);
        return toUserDetailResponse(updated);
    }

    @Override
    public void changePassword(Integer userId, ChangePasswordRequest request) {
        User existing = userRepository.findById(userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        if (!passwordEncoder.matches(request.getCurrentPassword(), existing.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Incorrect current password");
        }

        existing.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        existing.setUpdatedAt(LocalDateTime.now());
        userRepository.save(existing);
    }

    private UserListItemResponse toUserListItemResponse(User user) {
        return UserListItemResponse.builder()
            .id(user.getId())
            .fullname(user.getFullname())
            .username(user.getUsername())
            .email(user.getEmail())
            .role(user.getRole() == null ? "UNKNOWN" : user.getRole().getName())
            .status(user.getStatus())
            .idCard(user.getIdCard())
            .build();
    }

    private UserDetailResponse toUserDetailResponse(User user) {
        return UserDetailResponse.builder()
            .id(user.getId())
            .fullname(user.getFullname())
            .username(user.getUsername())
            .email(user.getEmail())
            .role(user.getRole() == null ? "UNKNOWN" : user.getRole().getName())
            .idCard(user.getIdCard())
            .phone(user.getPhone())
            .address(user.getAddress())
            .status(user.getStatus())
            .avatar(user.getAvatar())
            .lastLogin(formatDateTime(user.getLastLogin()))
            .dob(formatDate(user.getDob()))
            .schedule(buildSchedule(user.getId()))
            .build();
    }

    private String normalizeOptionalText(String text) {
        if (text == null) {
            return null;
        }
        String trimmed = text.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private Role resolveRole(String userRole) {
        String normalized = userRole == null ? "" : userRole.trim().toLowerCase();
        if (!normalized.isEmpty()) {
            var directRole = roleRepository.findByNameIgnoreCase(normalized);
            if (directRole.isPresent()) {
                return directRole.get();
            }
        }

        String roleName = switch (normalized) {
            case "administrator", "admin" -> "ADMIN";
            case "user" -> "CASHIER";
            default -> normalized.toUpperCase();
        };

        return roleRepository.findByNameIgnoreCase(roleName)
            .orElseThrow(() -> new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Role not found: " + userRole
            ));
    }

    private List<UserScheduleItemResponse> buildSchedule(Integer userId) {
        List<Shift> shifts = shiftRepository.findTop7ByUser_IdOrderByOpenTimeDesc(userId);
        LinkedHashMap<String, UserScheduleItemResponse> ordered = new LinkedHashMap<>();
        ordered.put("Monday", emptySchedule("Monday"));
        ordered.put("Tuesday", emptySchedule("Tuesday"));
        ordered.put("Wednesday", emptySchedule("Wednesday"));
        ordered.put("Thursday", emptySchedule("Thursday"));
        ordered.put("Friday", emptySchedule("Friday"));
        ordered.put("Saturday", emptySchedule("Saturday"));
        ordered.put("Sunday", emptySchedule("Sunday"));

        for (Shift shift : shifts) {
            if (shift.getOpenTime() == null) {
                continue;
            }
            String day = shift.getOpenTime().getDayOfWeek().getDisplayName(java.time.format.TextStyle.FULL, Locale.ENGLISH);
            if (!ordered.containsKey(day) || isEmptyItem(ordered.get(day))) {
                ordered.put(day, UserScheduleItemResponse.builder()
                    .day(day)
                    .loginTime(formatTime(shift.getOpenTime()))
                    .logoutTime(formatTime(shift.getCloseTime()))
                    .shiftRevenue(formatMoney(shift.getTotalCashEnd()))
                    .build());
            }
        }
        return new ArrayList<>(ordered.values());
    }

    private UserScheduleItemResponse emptySchedule(String day) {
        return UserScheduleItemResponse.builder()
            .day(day)
            .loginTime("—")
            .logoutTime("—")
            .shiftRevenue("—")
            .build();
    }

    private boolean isEmptyItem(UserScheduleItemResponse item) {
        return "—".equals(item.getLoginTime()) && "—".equals(item.getLogoutTime()) && "—".equals(item.getShiftRevenue());
    }

    private String formatDateTime(LocalDateTime dateTime) {
        return dateTime == null ? "—" : dateTime.format(DATE_TIME_FORMATTER);
    }

    private String formatTime(LocalDateTime dateTime) {
        return dateTime == null ? "—" : dateTime.format(TIME_FORMATTER);
    }

    private String formatMoney(BigDecimal amount) {
        return amount == null ? "—" : amount.stripTrailingZeros().toPlainString();
    }

    private String formatDate(LocalDate date) {
        return date == null ? "" : date.format(DATE_FORMATTER);
    }

    private LocalDate parseDob(String dob) {
        String normalized = normalizeOptionalText(dob);
        if (normalized == null) {
            return null;
        }
        try {
            return LocalDate.parse(normalized, DATE_FORMATTER);
        } catch (DateTimeParseException ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "DOB must be yyyy-MM-dd");
        }
    }
}


