package com.supermarket.supermarket.dto.response;

import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class SupplierListItemResponse {

    private Integer id;
    private String supplierName;
    private String companyName;
    private String email;
    private String phone;
    private String address;
    private String status;
    private LocalDateTime createdAt;
}
