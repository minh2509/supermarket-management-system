package com.supermarket.supermarket.dto.response;

import java.time.LocalDate;
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
public class ExpirationProductResponse {

    private Integer id;
    private String productName;
    private Integer inStock;
    private String supplierName;
    private LocalDate expiryDate;
    private String status;
}
