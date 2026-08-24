package com.supermarket.supermarket.controller;

import com.supermarket.supermarket.dto.request.CreateOrderRequest;
import com.supermarket.supermarket.dto.response.CheckoutOrderResponse;
import com.supermarket.supermarket.dto.response.DashboardSummaryResponse;
import com.supermarket.supermarket.dto.response.DashboardTransactionResponse;
import com.supermarket.supermarket.dto.response.OrderDetailResponse;
import com.supermarket.supermarket.dto.response.OrderListItemResponse;
import com.supermarket.supermarket.service.OrderService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestBody;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @GetMapping
    public ResponseEntity<List<OrderListItemResponse>> getAllOrders() {
        return ResponseEntity.ok(orderService.getAllOrders());
    }

    @GetMapping("/{id}")
    public ResponseEntity<OrderDetailResponse> getOrderDetail(@PathVariable("id") Integer id) {
        return ResponseEntity.ok(orderService.getOrderDetail(id));
    }

    @GetMapping("/dashboard")
    public ResponseEntity<DashboardSummaryResponse> getDashboardSummary() {
        return ResponseEntity.ok(orderService.getDashboardSummary());
    }

    @GetMapping("/today-transactions")
    public ResponseEntity<List<DashboardTransactionResponse>> getTodayTransactions() {
        return ResponseEntity.ok(orderService.getTodayTransactions());
    }

    @PostMapping("/checkout")
    public ResponseEntity<CheckoutOrderResponse> checkout(@Valid @RequestBody CreateOrderRequest request) {
        return ResponseEntity.ok(orderService.createOrder(request));
    }
}


