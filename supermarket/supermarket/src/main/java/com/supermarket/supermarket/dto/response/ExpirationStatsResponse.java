package com.supermarket.supermarket.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExpirationStatsResponse {

    private Integer expiresToday;
    private Integer expiresIn7Days;
    private Integer expiresIn3Months;
    private Integer expiresIn6Months;
}
