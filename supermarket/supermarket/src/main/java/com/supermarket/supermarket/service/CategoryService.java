package com.supermarket.supermarket.service;

import com.supermarket.supermarket.dto.request.CreateCategoryRequest;
import com.supermarket.supermarket.dto.request.UpdateCategoryRequest;
import com.supermarket.supermarket.dto.response.CategoryListItemResponse;
import com.supermarket.supermarket.dto.response.CategoryOptionResponse;
import java.util.List;

public interface CategoryService {

    List<CategoryOptionResponse> getAllCategoryOptions();

    List<CategoryListItemResponse> getAllCategories();

    CategoryListItemResponse getCategoryById(Integer id);

    CategoryListItemResponse createCategory(CreateCategoryRequest request);

    CategoryListItemResponse updateCategory(Integer id, UpdateCategoryRequest request);

    void deleteCategory(Integer id);
}
