package com.supermarket.supermarket.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateOrderRequest {

    @NotNull(message = "Cashier id is required")
    private Integer cashierId;

    @Size(max = 20, message = "Customer phone cannot exceed 20 chars")
    private String customerPhone;

    @Size(max = 100, message = "Customer name cannot exceed 100 chars")
    private String customerName;

    @Size(max = 100, message = "Sales point cannot exceed 100 chars")
    private String salesPoint;

    @Size(max = 20, message = "Payment method cannot exceed 20 chars")
    private String paymentMethod;

    private Integer discountId;

    @DecimalMin(value = "0.0", inclusive = true, message = "Discount percent must be >= 0")
    private BigDecimal discountPercent;

    @NotNull(message = "Paid amount is required")
    @DecimalMin(value = "0.0", inclusive = true, message = "Paid amount must be >= 0")
    private BigDecimal paid;

    @NotEmpty(message = "Order must contain at least one item")
    @Valid
    private List<CreateOrderItemRequest> items;

    @Getter
    @Setter
    public static class CreateOrderItemRequest {
        @NotNull(message = "Product id is required")
        private Integer productId;

        @NotNull(message = "Quantity is required")
        @Min(value = 1, message = "Quantity must be >= 1")
        private Integer qty;

        @DecimalMin(value = "0.0", inclusive = false, message = "Kg must be > 0 when provided")
        private BigDecimal kg;
    }
}
