package com.supermarket.supermarket.dto.request;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateDiscountRequest {
    @NotBlank(message = "Discount name is required")
    private String name;

    @NotNull(message = "Discount percent is required")
    @DecimalMin(value = "0", message = "Discount percent must be at least 0")
    @DecimalMax(value = "100", message = "Discount percent cannot exceed 100")
    private BigDecimal percent;

    @NotNull(message = "Min order amount is required")
    @PositiveOrZero(message = "Min order amount must be zero or positive")
    private BigDecimal minOrderAmount;

    @NotNull(message = "Start date is required")
    private LocalDate startDate;

    @NotNull(message = "End date is required")
    private LocalDate endDate;
}
