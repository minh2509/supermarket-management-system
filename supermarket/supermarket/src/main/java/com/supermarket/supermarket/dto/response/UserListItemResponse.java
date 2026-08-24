package com.supermarket.supermarket.dto.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class UserListItemResponse {
    private Integer id;
    private String fullname;
    private String username;
    private String email;
    private String role;
    private String status;
    private String idCard;
}
