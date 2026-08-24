package com.supermarket.supermarket.service.impl;

import com.supermarket.supermarket.dto.request.CreateDiscountRequest;
import com.supermarket.supermarket.dto.request.UpdateDiscountRequest;
import com.supermarket.supermarket.dto.response.DiscountResponse;
import com.supermarket.supermarket.entity.Discount;
import com.supermarket.supermarket.repository.DiscountRepository;
import com.supermarket.supermarket.service.DiscountService;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class DiscountServiceImpl implements DiscountService {

    private final DiscountRepository discountRepository;

    @Override
    public List<DiscountResponse> getAllDiscounts() {
        return discountRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public DiscountResponse getDiscountById(Integer id) {
        Discount discount = discountRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Discount not found with id: " + id));
        return mapToResponse(discount);
    }

    @Override
    @Transactional
    public DiscountResponse createDiscount(CreateDiscountRequest request) {
        if (request.getStartDate().isAfter(request.getEndDate())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Start date must be before or equal to end date");
        }
        Discount discount = Discount.builder()
                .name(request.getName())
                .percent(request.getPercent())
                .minOrderAmount(request.getMinOrderAmount())
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        
        return mapToResponse(discountRepository.save(discount));
    }

    @Override
    @Transactional
    public DiscountResponse updateDiscount(Integer id, UpdateDiscountRequest request) {
        if (request.getStartDate().isAfter(request.getEndDate())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Start date must be before or equal to end date");
        }
        Discount discount = discountRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Discount not found with id: " + id));
        
        discount.setName(request.getName());
        discount.setPercent(request.getPercent());
        discount.setMinOrderAmount(request.getMinOrderAmount());
        discount.setStartDate(request.getStartDate());
        discount.setEndDate(request.getEndDate());
        discount.setUpdatedAt(LocalDateTime.now());
        
        return mapToResponse(discountRepository.save(discount));
    }

    @Override
    @Transactional
    public void deleteDiscount(Integer id) {
        if (!discountRepository.existsById(id)) {
            throw new RuntimeException("Discount not found with id: " + id);
        }
        discountRepository.deleteById(id);
    }

    private DiscountResponse mapToResponse(Discount discount) {
        return DiscountResponse.builder()
                .id(discount.getId())
                .name(discount.getName())
                .percent(discount.getPercent())
                .minOrderAmount(discount.getMinOrderAmount())
                .startDate(discount.getStartDate())
                .endDate(discount.getEndDate())
                .build();
    }
}
