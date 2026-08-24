package com.supermarket.supermarket.service;

import com.supermarket.supermarket.dto.request.CreateUserRequest;
import com.supermarket.supermarket.dto.request.UpdateProfileRequest;
import com.supermarket.supermarket.dto.request.UpdateUserRequest;
import com.supermarket.supermarket.dto.response.UserDetailResponse;
import com.supermarket.supermarket.dto.response.RoleOptionResponse;
import com.supermarket.supermarket.dto.response.UserListItemResponse;
import java.util.List;

public interface UserService {
    List<UserListItemResponse> getAllUsers();

    UserListItemResponse createUser(CreateUserRequest request);

    List<RoleOptionResponse> getAllRoles();

    UserDetailResponse getUserDetail(Integer userId);

    UserListItemResponse updateUser(Integer userId, UpdateUserRequest request);

    UserListItemResponse updateUserStatus(Integer userId, String status);

    UserDetailResponse updateProfile(Integer userId, UpdateProfileRequest request);

    void changePassword(Integer userId, com.supermarket.supermarket.dto.request.ChangePasswordRequest request);
}
