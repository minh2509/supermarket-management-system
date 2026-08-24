package com.supermarket.supermarket.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdateSupplierRequest {

    @NotBlank(message = "Supplier name is required")
    @Size(max = 100, message = "Supplier name must be <= 100 characters")
    private String supplierName;

    @Size(max = 150, message = "Company name must be <= 150 characters")
    private String companyName;

    @Size(max = 100, message = "Email must be <= 100 characters")
    private String email;

    @Size(max = 20, message = "Phone must be <= 20 characters")
    private String phone;

    @Size(max = 255, message = "Address must be <= 255 characters")
    private String address;

    @Size(max = 20, message = "Status must be <= 20 characters")
    private String status;
}
