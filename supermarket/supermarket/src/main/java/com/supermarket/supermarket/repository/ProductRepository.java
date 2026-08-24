package com.supermarket.supermarket.repository;

import com.supermarket.supermarket.entity.Product;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductRepository extends JpaRepository<Product, Integer> {

    List<Product> findAllByOrderByIdAsc();

    boolean existsByBarcode(String barcode);

    long countByInStockGreaterThan(int minStock);

    long countByExpiryDateBefore(java.time.LocalDate date);

    long countByCreatedAtAfter(java.time.LocalDateTime dateTime);
}

