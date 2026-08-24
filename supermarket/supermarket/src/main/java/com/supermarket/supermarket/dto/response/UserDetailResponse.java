package com.supermarket.supermarket.dto.response;

import java.util.List;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class UserDetailResponse {
    private Integer id;
    private String fullname;
    private String username;
    private String email;
    private String role;
    private String idCard;
    private String phone;
    private String address;
    private String status;
    private String avatar;
    private String lastLogin;
    private String dob;
    private List<UserScheduleItemResponse> schedule;
}
