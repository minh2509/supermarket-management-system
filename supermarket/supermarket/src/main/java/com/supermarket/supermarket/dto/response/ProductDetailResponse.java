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
public class ProductDetailResponse {

    private Integer id;
    private String barcode;
    private String productName;
    private String productBatch;
    private String description;
    private BigDecimal costPrice;
    private BigDecimal sellingPrice;
    private Integer qtyCartons;
    private Integer inStock;
    private String supplierName;
    private String categoryName;
    private LocalDate mftDate;
    private LocalDate expiryDate;
    private String status;
    private String imageUrl;
}

