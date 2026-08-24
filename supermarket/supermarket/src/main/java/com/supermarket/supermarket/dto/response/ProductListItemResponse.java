package com.supermarket.supermarket.dto.response;

import java.math.BigDecimal;
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
public class ProductListItemResponse {

    private Integer id;
    private String barcode;
    private String productName;
    private String categoryName;
    private LocalDate expiryDate;
    private BigDecimal sellingPrice;
    private Integer inStock;
    private String status;
}

