package com.supermarket.supermarket.dto.response;

import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RevenueReportItemResponse {
    private String label;
    private BigDecimal totalRevenue;
    private long orderCount;
}
