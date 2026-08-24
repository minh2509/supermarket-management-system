package com.supermarket.supermarket.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdateProfileRequest {

    @NotBlank(message = "Fullname is required")
    @Size(max = 100, message = "Fullname must be <= 100 characters")
    private String fullname;

    @NotBlank(message = "Email is required")
    @Pattern(regexp = ".*@.*", message = "Email must contain @")
    @Size(max = 100, message = "Email must be <= 100 characters")
    private String email;

    @Size(max = 20, message = "ID card must be <= 20 characters")
    private String idCard;

    @Size(max = 20, message = "Phone must be <= 20 characters")
    private String phone;

    @Size(max = 255, message = "Address must be <= 255 characters")
    private String address;

    @Size(max = 10, message = "DOB must be in yyyy-MM-dd format")
    private String dob;
}
