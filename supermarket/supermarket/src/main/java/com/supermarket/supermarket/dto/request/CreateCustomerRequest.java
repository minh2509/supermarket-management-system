package com.supermarket.supermarket.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
public class CreateCustomerRequest {

    @NotBlank(message = "Customer name is required")
    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    @Pattern(regexp = "^[a-zA-Z\\s\\u00C0-\\u024F\\u1E00-\\u1EFF]+$", message = "Name must only contain letters")
    private String name;

    @NotBlank(message = "Phone is required")
    @Pattern(regexp = "^(0|84)(3|5|7|8|9)([0-9]{8})$", message = "Invalid Vietnamese phone number format")
    private String phone;

    @PositiveOrZero(message = "Total amount must be zero or positive")
    private BigDecimal totalAmount;
}
