package com.supermarket.supermarket.dto.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class OrderListItemResponse {
    private Integer id;
    private String orderNo;
    private String orderDateTime;
    private String customerName;
    private String customerPhone;
    private BigDecimal total;
    private BigDecimal discountPercent;
    private BigDecimal payable;
    private BigDecimal paid;
    private String paymentMethod;
    private String status;
    private String cashierName;
    private LocalDateTime createdAt;
}

