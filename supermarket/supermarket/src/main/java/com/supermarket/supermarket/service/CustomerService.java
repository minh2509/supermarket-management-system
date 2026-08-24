package com.supermarket.supermarket.service;

import com.supermarket.supermarket.dto.request.CreateCustomerRequest;
import com.supermarket.supermarket.dto.request.UpdateCustomerRequest;
import com.supermarket.supermarket.dto.response.CustomerDetailResponse;
import com.supermarket.supermarket.dto.response.CustomerListItemResponse;
import com.supermarket.supermarket.dto.response.OrderListItemResponse;
import java.util.List;

public interface CustomerService {

    List<CustomerListItemResponse> getAllCustomers();

    CustomerDetailResponse getCustomerDetail(Integer id);

    CustomerListItemResponse getCustomerByPhone(String phone);

    CustomerListItemResponse createCustomer(CreateCustomerRequest request);

    CustomerListItemResponse updateCustomer(Integer id, UpdateCustomerRequest request);

    List<OrderListItemResponse> getCustomerOrderHistory(Integer customerId);
}
