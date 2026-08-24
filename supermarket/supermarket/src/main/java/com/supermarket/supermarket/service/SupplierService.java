package com.supermarket.supermarket.service;

import com.supermarket.supermarket.dto.request.CreateSupplierRequest;
import com.supermarket.supermarket.dto.request.UpdateSupplierRequest;
import com.supermarket.supermarket.dto.response.SupplierListItemResponse;
import com.supermarket.supermarket.dto.response.SupplierOptionResponse;
import java.util.List;

public interface SupplierService {

    List<SupplierListItemResponse> getAllSuppliers();

    SupplierListItemResponse getSupplierById(Integer id);

    SupplierListItemResponse createSupplier(CreateSupplierRequest request);

    SupplierListItemResponse updateSupplier(Integer id, UpdateSupplierRequest request);

    void deleteSupplier(Integer id);

    List<SupplierOptionResponse> getAllSupplierOptions();
}
