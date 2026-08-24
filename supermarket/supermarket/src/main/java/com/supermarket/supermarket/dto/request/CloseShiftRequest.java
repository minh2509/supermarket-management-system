package com.supermarket.supermarket.dto.request;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CloseShiftRequest {

    @NotNull(message = "Closing cash is required")
    @DecimalMin(value = "0.0", message = "Closing cash cannot be negative")
    private BigDecimal totalCashEnd;
}
