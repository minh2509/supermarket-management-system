package com.supermarket.supermarket.dto.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardTransactionResponse {
    private String orderNo;
    private String paymentMethod;
    private BigDecimal totalPayable;
    private String cashierName;
    private String status;
    private LocalDateTime createdAt;
}
