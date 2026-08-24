package com.supermarket.supermarket.service;

import com.supermarket.supermarket.dto.request.CreateOrderRequest;
import com.supermarket.supermarket.dto.response.CheckoutOrderResponse;
import com.supermarket.supermarket.dto.response.DashboardSummaryResponse;
import com.supermarket.supermarket.dto.response.DashboardTransactionResponse;
import com.supermarket.supermarket.dto.response.OrderListItemResponse;
import com.supermarket.supermarket.dto.response.OrderDetailResponse;
import java.util.List;

public interface OrderService {
    List<OrderListItemResponse> getAllOrders();

    OrderDetailResponse getOrderDetail(Integer orderId);

    List<OrderListItemResponse> getOrdersByCustomerId(Integer customerId);

    DashboardSummaryResponse getDashboardSummary();

    List<DashboardTransactionResponse> getTodayTransactions();

    CheckoutOrderResponse createOrder(CreateOrderRequest request);
}


