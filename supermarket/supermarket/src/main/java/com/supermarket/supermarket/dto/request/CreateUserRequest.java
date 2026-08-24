package com.supermarket.supermarket.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateUserRequest {

    @NotBlank(message = "Fullname is required")
    @Size(max = 100, message = "Fullname must be <= 100 characters")
    private String fullname;

    @NotBlank(message = "Username is required")
    @Size(max = 50, message = "Username must be <= 50 characters")
    private String username;

    @NotBlank(message = "Email is required")
    @Pattern(regexp = ".*@.*", message = "Email must contain @")
    @Size(max = 100, message = "Email must be <= 100 characters")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 8, max = 100, message = "Password must be at least 8 characters")
    private String password;

    @Size(max = 20, message = "ID card must be <= 20 characters")
    private String idCard;

    @NotBlank(message = "User role is required")
    private String userRole;
}
