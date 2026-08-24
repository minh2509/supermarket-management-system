package com.supermarket.supermarket.dto.response;

import java.math.BigDecimal;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DiscountResponse {
    private Integer id;
    private String name;
    private BigDecimal percent;
    private BigDecimal minOrderAmount;
    private LocalDate startDate;
    private LocalDate endDate;
}
