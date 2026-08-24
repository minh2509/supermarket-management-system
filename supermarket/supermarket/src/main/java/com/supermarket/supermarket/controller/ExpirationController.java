package com.supermarket.supermarket.controller;

import com.supermarket.supermarket.dto.response.ExpirationProductResponse;
import com.supermarket.supermarket.dto.response.ExpirationStatsResponse;
import com.supermarket.supermarket.service.ExpirationService;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/expiration")
@RequiredArgsConstructor
public class ExpirationController {

    private final ExpirationService expirationService;

    @GetMapping("/stats")
    public ResponseEntity<ExpirationStatsResponse> getExpirationStats() {
        return ResponseEntity.ok(expirationService.getExpirationStats());
    }

    @GetMapping("/today")
    public ResponseEntity<List<ExpirationProductResponse>> getProductsExpiringToday() {
        return ResponseEntity.ok(expirationService.getProductsExpiringToday());
    }

    @GetMapping("/7days")
    public ResponseEntity<List<ExpirationProductResponse>> getProductsExpiringIn7Days() {
        return ResponseEntity.ok(expirationService.getProductsExpiringIn7Days());
    }

    @GetMapping("/3months")
    public ResponseEntity<List<ExpirationProductResponse>> getProductsExpiringIn3Months() {
        return ResponseEntity.ok(expirationService.getProductsExpiringIn3Months());
    }

    @GetMapping("/6months")
    public ResponseEntity<List<ExpirationProductResponse>> getProductsExpiringIn6Months() {
        return ResponseEntity.ok(expirationService.getProductsExpiringIn6Months());
    }
}
