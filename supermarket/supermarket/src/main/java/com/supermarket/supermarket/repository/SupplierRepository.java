package com.supermarket.supermarket.repository;

import com.supermarket.supermarket.entity.Supplier;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SupplierRepository extends JpaRepository<Supplier, Integer> {

    List<Supplier> findAllByOrderByIdAsc();
}
