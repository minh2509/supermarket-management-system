package com.supermarket.supermarket.dto.response;

import java.math.BigDecimal;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class CustomerListItemResponse {
    private Integer id;
    private String name;
    private String phone;
    private Integer points;
    private Integer totalPurchases;
    private BigDecimal totalAmount;
    private BigDecimal discountPercent;
}
