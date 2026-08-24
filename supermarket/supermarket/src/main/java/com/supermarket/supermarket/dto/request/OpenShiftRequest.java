package com.supermarket.supermarket.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class OpenShiftRequest {

    @NotNull(message = "User ID is required")
    private Integer userId;

    @NotNull(message = "Opening cash is required")
    @DecimalMin(value = "0.0", message = "Opening cash cannot be negative")
    private BigDecimal initialCash;

    private String salesPoint;
}
