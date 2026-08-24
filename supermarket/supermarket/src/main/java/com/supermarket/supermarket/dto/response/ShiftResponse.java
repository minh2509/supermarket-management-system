package com.supermarket.supermarket.dto.response;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ShiftResponse {
    private Integer id;
    private Integer userId;
    private String employeeName;
    private String salesPoint;
    private LocalDateTime openTime;
    private LocalDateTime closeTime;
    private BigDecimal initialCash;
    private BigDecimal cashRevenue;
    private BigDecimal revenue;
    private BigDecimal systemCashEnd;
    private BigDecimal totalCashEnd;
    private BigDecimal difference;
    private long orderCount;
    private String status;
}
