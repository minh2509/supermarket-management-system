package com.supermarket.supermarket.dto.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class UserScheduleItemResponse {
    private String day;
    private String loginTime;
    private String logoutTime;
    private String shiftRevenue;
}
