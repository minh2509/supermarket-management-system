package com.supermarket.supermarket.dto.response;

import java.math.BigDecimal;
import java.util.List;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class OrderDetailResponse {
    private Integer id;
    private String orderNo;
    private String customerPhone;
    private String cashierName;
    private BigDecimal subtotal;
    private BigDecimal discountPercent;
    private BigDecimal discountAmount;
    private BigDecimal totalPayment;
    private List<OrderDetailItemResponse> items;
}

