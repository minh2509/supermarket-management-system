package com.supermarket.supermarket.controller;

import com.supermarket.supermarket.dto.request.CreateUserRequest;
import com.supermarket.supermarket.dto.request.UpdateProfileRequest;
import com.supermarket.supermarket.dto.request.UpdateUserRequest;
import com.supermarket.supermarket.dto.request.UpdateUserStatusRequest;
import com.supermarket.supermarket.dto.request.ChangePasswordRequest;
import com.supermarket.supermarket.dto.response.RoleOptionResponse;
import com.supermarket.supermarket.dto.response.UserDetailResponse;
import com.supermarket.supermarket.dto.response.UserListItemResponse;
import com.supermarket.supermarket.service.UserService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.PatchMapping;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping
    public ResponseEntity<List<UserListItemResponse>> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    @GetMapping("/roles")
    public ResponseEntity<List<RoleOptionResponse>> getAllRoles() {
        return ResponseEntity.ok(userService.getAllRoles());
    }

    @PostMapping
    public ResponseEntity<UserListItemResponse> createUser(@Valid @RequestBody CreateUserRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(userService.createUser(request));
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserDetailResponse> getUserDetail(@PathVariable("id") Integer id) {
        return ResponseEntity.ok(userService.getUserDetail(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<UserListItemResponse> updateUser(
        @PathVariable("id") Integer id,
        @Valid @RequestBody UpdateUserRequest request
    ) {
        return ResponseEntity.ok(userService.updateUser(id, request));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<UserListItemResponse> updateUserStatus(
        @PathVariable("id") Integer id,
        @Valid @RequestBody UpdateUserStatusRequest request
    ) {
        return ResponseEntity.ok(userService.updateUserStatus(id, request.getStatus()));
    }

    @PutMapping("/{id}/profile")
    public ResponseEntity<UserDetailResponse> updateProfile(
        @PathVariable("id") Integer id,
        @Valid @RequestBody UpdateProfileRequest request
    ) {
        return ResponseEntity.ok(userService.updateProfile(id, request));
    }

    @PutMapping("/{id}/password")
    public ResponseEntity<Void> changePassword(
        @PathVariable("id") Integer id,
        @Valid @RequestBody ChangePasswordRequest request
    ) {
        userService.changePassword(id, request);
        return ResponseEntity.ok().build();
    }
}
