package com.supermarket.supermarket.service;

import com.supermarket.supermarket.dto.request.CreateDiscountRequest;
import com.supermarket.supermarket.dto.request.UpdateDiscountRequest;
import com.supermarket.supermarket.dto.response.DiscountResponse;
import java.util.List;

public interface DiscountService {
    List<DiscountResponse> getAllDiscounts();
    DiscountResponse getDiscountById(Integer id);
    DiscountResponse createDiscount(CreateDiscountRequest request);
    DiscountResponse updateDiscount(Integer id, UpdateDiscountRequest request);
    void deleteDiscount(Integer id);
}
