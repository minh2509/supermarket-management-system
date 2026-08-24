package com.supermarket.supermarket.service;

import com.supermarket.supermarket.dto.response.ExpirationProductResponse;
import com.supermarket.supermarket.dto.response.ExpirationStatsResponse;
import java.util.List;

public interface ExpirationService {

    ExpirationStatsResponse getExpirationStats();

    List<ExpirationProductResponse> getProductsExpiringToday();

    List<ExpirationProductResponse> getProductsExpiringIn7Days();

    List<ExpirationProductResponse> getProductsExpiringIn3Months();

    List<ExpirationProductResponse> getProductsExpiringIn6Months();
}
