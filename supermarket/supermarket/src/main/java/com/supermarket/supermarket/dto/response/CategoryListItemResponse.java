package com.supermarket.supermarket.dto.response;

import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class CategoryListItemResponse {

    private Integer id;
    private String name;
    private String status;
    private LocalDateTime createdAt;
}

