package com.supermarket.supermarket.dto.response;

import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardSummaryResponse {
    private BigDecimal todaySales;
    private long expiredProducts;
    private long todayInvoiceCount;
    private long newProductsCount;
    private long supplierCount;
    private long invoiceCount;
    private BigDecimal currentMonthSales;
    private BigDecimal last3MonthSales;
    private BigDecimal last6MonthSales;
    private long userCount;
    private long availableProductsCount;
    private BigDecimal currentYearRevenue;
    private List<TopProductResponse> topProducts;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TopProductResponse {
        private String name;
        private long totalQty;
    }
}
