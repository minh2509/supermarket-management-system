package com.supermarket.supermarket.dto.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class LoginResponse {
    private boolean success;
    private String message;
    private Integer userId;
    private Integer roleId;
    private String username;
    private String fullName;
    private String role;
    private String redirectTo;
}
