package com.supermarket.supermarket.dto.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class RoleOptionResponse {
    private Integer id;
    private String name;
}
