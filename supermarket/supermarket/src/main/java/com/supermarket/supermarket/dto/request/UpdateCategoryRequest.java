package com.supermarket.supermarket.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdateCategoryRequest {

    @NotBlank(message = "Category name is required")
    @Size(max = 100, message = "Category name must be <= 100 characters")
    private String name;

    @Size(max = 20, message = "Status must be <= 20 characters")
    private String status;
}

