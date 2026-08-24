package com.supermarket.supermarket.controller;

import com.supermarket.supermarket.dto.request.CreateCustomerRequest;
import com.supermarket.supermarket.dto.request.UpdateCustomerRequest;
import com.supermarket.supermarket.dto.response.CustomerDetailResponse;
import com.supermarket.supermarket.dto.response.CustomerListItemResponse;
import com.supermarket.supermarket.dto.response.OrderListItemResponse;
import com.supermarket.supermarket.service.CustomerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/customers")
@RequiredArgsConstructor
public class CustomerController {

    private final CustomerService customerService;

    @GetMapping
    public List<CustomerListItemResponse> getAllCustomers() {
        return customerService.getAllCustomers();
    }

    @GetMapping("/{id}")
    public CustomerDetailResponse getCustomerDetail(@PathVariable Integer id) {
        return customerService.getCustomerDetail(id);
    }

    @GetMapping("/by-phone")
    public CustomerListItemResponse getCustomerByPhone(@RequestParam String phone) {
        return customerService.getCustomerByPhone(phone);
    }

    @PostMapping
    public CustomerListItemResponse createCustomer(@Valid @RequestBody CreateCustomerRequest request) {
        return customerService.createCustomer(request);
    }

    @PutMapping("/{id}")
    public CustomerListItemResponse updateCustomer(
            @PathVariable Integer id,
            @Valid @RequestBody UpdateCustomerRequest request) {
        return customerService.updateCustomer(id, request);
    }

    @GetMapping("/{id}/history")
    public List<OrderListItemResponse> getCustomerOrderHistory(@PathVariable Integer id) {
        return customerService.getCustomerOrderHistory(id);
    }
}
