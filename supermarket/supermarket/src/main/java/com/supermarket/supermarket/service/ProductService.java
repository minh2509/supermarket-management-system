package com.supermarket.supermarket.service;

import com.supermarket.supermarket.dto.request.CreateProductRequest;
import com.supermarket.supermarket.dto.request.UpdateProductRequest;
import com.supermarket.supermarket.dto.response.ProductListItemResponse;
import com.supermarket.supermarket.dto.response.ProductDetailResponse;
import java.util.List;

public interface ProductService {

    List<ProductListItemResponse> getAllProducts();

    ProductDetailResponse getProductDetail(Integer id);

    ProductDetailResponse createProduct(CreateProductRequest request);

    ProductDetailResponse updateProduct(Integer id, UpdateProductRequest request);

    void deleteProduct(Integer id);
}

