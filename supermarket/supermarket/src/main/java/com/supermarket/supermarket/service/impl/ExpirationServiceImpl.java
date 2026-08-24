package com.supermarket.supermarket.service.impl;

import com.supermarket.supermarket.dto.response.ExpirationProductResponse;
import com.supermarket.supermarket.dto.response.ExpirationStatsResponse;
import com.supermarket.supermarket.entity.Product;
import com.supermarket.supermarket.repository.ProductRepository;
import com.supermarket.supermarket.service.ExpirationService;
import java.time.LocalDate;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ExpirationServiceImpl implements ExpirationService {

    private final ProductRepository productRepository;

    @Override
    @Transactional(readOnly = true)
    public ExpirationStatsResponse getExpirationStats() {
        LocalDate today = LocalDate.now();
        LocalDate in7Days = today.plusDays(7);
        LocalDate in3Months = today.plusMonths(3);
        LocalDate in6Months = today.plusMonths(6);

        List<Product> allProducts = productRepository.findAll();

        int expiresToday = (int) allProducts.stream()
            .filter(p -> p.getExpiryDate() != null && p.getExpiryDate().isEqual(today))
            .count();

        int expiresIn7Days = (int) allProducts.stream()
            .filter(p -> p.getExpiryDate() != null 
                && !p.getExpiryDate().isBefore(today)
                && !p.getExpiryDate().isAfter(in7Days))
            .count();

        int expiresIn3Months = (int) allProducts.stream()
            .filter(p -> p.getExpiryDate() != null 
                && !p.getExpiryDate().isBefore(today)
                && !p.getExpiryDate().isAfter(in3Months))
            .count();

        int expiresIn6Months = (int) allProducts.stream()
            .filter(p -> p.getExpiryDate() != null 
                && !p.getExpiryDate().isBefore(today)
                && !p.getExpiryDate().isAfter(in6Months))
            .count();

        return ExpirationStatsResponse.builder()
            .expiresToday(expiresToday)
            .expiresIn7Days(expiresIn7Days)
            .expiresIn3Months(expiresIn3Months)
            .expiresIn6Months(expiresIn6Months)
            .build();
    }

    @Override
    @Transactional(readOnly = true)
    public List<ExpirationProductResponse> getProductsExpiringToday() {
        LocalDate today = LocalDate.now();
        return productRepository.findAll().stream()
            .filter(p -> p.getExpiryDate() != null && p.getExpiryDate().isEqual(today))
            .map(this::toExpirationResponse)
            .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<ExpirationProductResponse> getProductsExpiringIn7Days() {
        LocalDate today = LocalDate.now();
        LocalDate in7Days = today.plusDays(7);
        return productRepository.findAll().stream()
            .filter(p -> p.getExpiryDate() != null 
                && !p.getExpiryDate().isBefore(today)
                && !p.getExpiryDate().isAfter(in7Days))
            .map(this::toExpirationResponse)
            .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<ExpirationProductResponse> getProductsExpiringIn3Months() {
        LocalDate today = LocalDate.now();
        LocalDate in3Months = today.plusMonths(3);
        return productRepository.findAll().stream()
            .filter(p -> p.getExpiryDate() != null 
                && !p.getExpiryDate().isBefore(today)
                && !p.getExpiryDate().isAfter(in3Months))
            .map(this::toExpirationResponse)
            .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<ExpirationProductResponse> getProductsExpiringIn6Months() {
        LocalDate today = LocalDate.now();
        LocalDate in6Months = today.plusMonths(6);
        return productRepository.findAll().stream()
            .filter(p -> p.getExpiryDate() != null 
                && !p.getExpiryDate().isBefore(today)
                && !p.getExpiryDate().isAfter(in6Months))
            .map(this::toExpirationResponse)
            .toList();
    }

    private ExpirationProductResponse toExpirationResponse(Product p) {
        String status = calculateExpirationStatus(p.getExpiryDate());
        return ExpirationProductResponse.builder()
            .id(p.getId())
            .productName(p.getProductName())
            .inStock(p.getInStock() != null ? p.getInStock() : 0)
            .supplierName(p.getSupplier() != null ? p.getSupplier().getSupplierName() : null)
            .expiryDate(p.getExpiryDate())
            .status(status)
            .build();
    }

    private String calculateExpirationStatus(LocalDate expiryDate) {
        if (expiryDate == null) {
            return "Unknown";
        }
        LocalDate today = LocalDate.now();
        long daysUntilExpiry = java.time.temporal.ChronoUnit.DAYS.between(today, expiryDate);

        if (daysUntilExpiry < 0) {
            return "Expired";
        } else if (daysUntilExpiry == 0) {
            return "Expires Today";
        } else if (daysUntilExpiry <= 7) {
            return "Soon";
        } else if (daysUntilExpiry <= 30) {
            return "Warning";
        } else {
            return "OK";
        }
    }
}
