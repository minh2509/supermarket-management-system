package com.supermarket.supermarket.dto.response;

import java.math.BigDecimal;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class OrderDetailItemResponse {
    private String productName;
    private BigDecimal unitPrice;
    private Integer qty;
    private BigDecimal amount;
}

