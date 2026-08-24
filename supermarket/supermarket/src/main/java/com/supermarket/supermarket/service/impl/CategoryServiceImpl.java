package com.supermarket.supermarket.service.impl;

import com.supermarket.supermarket.dto.request.CreateCategoryRequest;
import com.supermarket.supermarket.dto.request.UpdateCategoryRequest;
import com.supermarket.supermarket.dto.response.CategoryListItemResponse;
import com.supermarket.supermarket.dto.response.CategoryOptionResponse;
import com.supermarket.supermarket.repository.CategoryRepository;
import com.supermarket.supermarket.service.CategoryService;
import com.supermarket.supermarket.entity.Category;
import java.time.LocalDateTime;
import org.springframework.http.HttpStatus;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class CategoryServiceImpl implements CategoryService {

    private final CategoryRepository categoryRepository;

    @Override
    @Transactional(readOnly = true)
    public List<CategoryListItemResponse> getAllCategories() {
        return categoryRepository.findAll().stream()
            .map(this::toListItemResponse)
            .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public CategoryListItemResponse getCategoryById(Integer id) {
        Category category = categoryRepository.findById(id)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Category not found with id: " + id));
        return toListItemResponse(category);
    }

    @Override
    public CategoryListItemResponse createCategory(CreateCategoryRequest request) {
        String status = (request.getStatus() != null && !request.getStatus().isBlank())
            ? request.getStatus().trim()
            : "active";

        LocalDateTime now = LocalDateTime.now();
        Category category = Category.builder()
            .name(request.getName().trim())
            .status(status)
            .createdAt(now)
            .updatedAt(now)
            .build();

        category = categoryRepository.save(category);
        return toListItemResponse(category);
    }

    @Override
    public CategoryListItemResponse updateCategory(Integer id, UpdateCategoryRequest request) {
        Category category = categoryRepository.findById(id)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Category not found with id: " + id));

        String status = (request.getStatus() != null && !request.getStatus().isBlank())
            ? request.getStatus().trim()
            : "active";

        category.setName(request.getName().trim());
        category.setStatus(status);
        category.setUpdatedAt(LocalDateTime.now());

        category = categoryRepository.save(category);
        return toListItemResponse(category);
    }

    @Override
    public void deleteCategory(Integer id) {
        if (!categoryRepository.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Category not found with id: " + id);
        }
        try {
            categoryRepository.deleteById(id);
        } catch (DataIntegrityViolationException ex) {
            throw new ResponseStatusException(
                HttpStatus.CONFLICT,
                "Cannot delete category because it is being used by products."
            );
        }
    }

    private CategoryListItemResponse toListItemResponse(Category c) {
        return CategoryListItemResponse.builder()
            .id(c.getId())
            .name(c.getName())
            .status(c.getStatus())
            .createdAt(c.getCreatedAt())
            .build();
    }

    @Override
    @Transactional(readOnly = true)
    public List<CategoryOptionResponse> getAllCategoryOptions() {
        return categoryRepository.findAll().stream()
            .map(c -> CategoryOptionResponse.builder()
                .id(c.getId())
                .name(c.getName())
                .build())
            .toList();
    }
}
