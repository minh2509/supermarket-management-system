package com.supermarket.supermarket.dto.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class CustomerDetailResponse {
    private Integer id;
    private String name;
    private String phone;
    private Integer points;
    private Integer totalPurchases;
    private BigDecimal totalAmount;
    private Integer discountId;
    private String discountName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
