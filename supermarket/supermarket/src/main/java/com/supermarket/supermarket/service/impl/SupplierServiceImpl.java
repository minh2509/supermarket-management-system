package com.supermarket.supermarket.service.impl;

import com.supermarket.supermarket.dto.request.CreateSupplierRequest;
import com.supermarket.supermarket.dto.request.UpdateSupplierRequest;
import com.supermarket.supermarket.dto.response.SupplierListItemResponse;
import com.supermarket.supermarket.dto.response.SupplierOptionResponse;
import com.supermarket.supermarket.entity.Supplier;
import com.supermarket.supermarket.repository.SupplierRepository;
import com.supermarket.supermarket.service.SupplierService;
import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class SupplierServiceImpl implements SupplierService {

    private final SupplierRepository supplierRepository;

    @Override
    public List<SupplierListItemResponse> getAllSuppliers() {
        return supplierRepository.findAllByOrderByIdAsc()
            .stream()
            .map(this::toListItemResponse)
            .toList();
    }

    @Override
    public SupplierListItemResponse getSupplierById(Integer id) {
        return supplierRepository.findById(id)
            .map(this::toListItemResponse)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Supplier not found with id: " + id));
    }

    @Override
    public SupplierListItemResponse createSupplier(CreateSupplierRequest request) {
        String status = (request.getStatus() != null && !request.getStatus().isBlank())
            ? request.getStatus().trim()
            : "active";
        LocalDateTime now = LocalDateTime.now();
        Supplier supplier = Supplier.builder()
            .supplierName(request.getSupplierName().trim())
            .companyName(trimOrNull(request.getCompanyName()))
            .email(trimOrNull(request.getEmail()))
            .phone(trimOrNull(request.getPhone()))
            .address(trimOrNull(request.getAddress()))
            .status(status)
            .createdAt(now)
            .updatedAt(now)
            .build();
        supplier = supplierRepository.save(supplier);
        return toListItemResponse(supplier);
    }

    @Override
    public SupplierListItemResponse updateSupplier(Integer id, UpdateSupplierRequest request) {
        Supplier supplier = supplierRepository.findById(id)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Supplier not found with id: " + id));
        String status = (request.getStatus() != null && !request.getStatus().isBlank())
            ? request.getStatus().trim()
            : "active";
        supplier.setSupplierName(request.getSupplierName().trim());
        supplier.setCompanyName(trimOrNull(request.getCompanyName()));
        supplier.setEmail(trimOrNull(request.getEmail()));
        supplier.setPhone(trimOrNull(request.getPhone()));
        supplier.setAddress(trimOrNull(request.getAddress()));
        supplier.setStatus(status);
        supplier.setUpdatedAt(LocalDateTime.now());
        supplier = supplierRepository.save(supplier);
        return toListItemResponse(supplier);
    }

    @Override
    public void deleteSupplier(Integer id) {
        if (!supplierRepository.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Supplier not found with id: " + id);
        }
        supplierRepository.deleteById(id);
    }

    private static String trimOrNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }

    private SupplierListItemResponse toListItemResponse(Supplier s) {
        return SupplierListItemResponse.builder()
            .id(s.getId())
            .supplierName(s.getSupplierName())
            .companyName(s.getCompanyName())
            .email(s.getEmail())
            .phone(s.getPhone())
            .address(s.getAddress())
            .status(s.getStatus())
            .createdAt(s.getCreatedAt())
            .build();
    }

    @Override
    @Transactional(readOnly = true)
    public List<SupplierOptionResponse> getAllSupplierOptions() {
        return supplierRepository.findAll().stream()
            .map(s -> SupplierOptionResponse.builder()
                .id(s.getId())
                .supplierName(s.getSupplierName())
                .build())
            .toList();
    }
}
