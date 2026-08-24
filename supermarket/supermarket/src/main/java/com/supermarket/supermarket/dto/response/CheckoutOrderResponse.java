package com.supermarket.supermarket.dto.response;

import java.math.BigDecimal;
import java.util.List;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class CheckoutOrderResponse {
    private Integer orderId;
    private String orderNo;
    private String customerName;
    private String customerPhone;
    private String cashierName;
    private String salesPoint;
    private String orderDate;
    private String orderTime;
    private BigDecimal subtotal;
    private BigDecimal discountPercent;
    private BigDecimal discountAmount;
    private BigDecimal totalPayable;
    private BigDecimal paid;
    private BigDecimal balance;
    private String paymentMethod;
    private List<CheckoutOrderItemResponse> items;

    @Getter
    @Builder
    public static class CheckoutOrderItemResponse {
        private String productName;
        private BigDecimal unitPrice;
        private Integer qty;
        private BigDecimal amount;
    }
}
