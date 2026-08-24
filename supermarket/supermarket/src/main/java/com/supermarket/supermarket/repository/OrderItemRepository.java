package com.supermarket.supermarket.repository;

import com.supermarket.supermarket.entity.OrderItem;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.domain.Pageable;

public interface OrderItemRepository extends JpaRepository<OrderItem, Integer> {
    List<OrderItem> findByOrder_IdOrderByIdAsc(Integer orderId);

    @Query("SELECT i.productName, SUM(i.qty) as totalQty " +
           "FROM OrderItem i " +
           "GROUP BY i.productName " +
           "ORDER BY totalQty DESC")
    List<Object[]> findTopSellingProducts(Pageable pageable);
}

