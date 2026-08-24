package com.supermarket.supermarket.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UpdateProductRequest {

    @Size(max = 50, message = "Product batch must be <= 50 characters")
    private String productBatch;

    @NotBlank(message = "Product name is required")
    @Size(max = 150, message = "Product name must be <= 150 characters")
    private String productName;

    @Size(max = 500, message = "Description must be <= 500 characters")
    private String description;

    @DecimalMin(value = "0.0", inclusive = true, message = "Cost price must be >= 0")
    private BigDecimal costPrice;

    @NotNull(message = "Selling price is required")
    @DecimalMin(value = "0.0", inclusive = false, message = "Selling price must be > 0")
    private BigDecimal sellingPrice;

    private Integer qtyCartons;

    private Integer inStock;

    private Integer supplierId;

    private Integer categoryId;

    private LocalDate mftDate;

    private LocalDate expiryDate;

    @Size(max = 500, message = "Image URL must be <= 500 characters")
    private String imageUrl;
}
