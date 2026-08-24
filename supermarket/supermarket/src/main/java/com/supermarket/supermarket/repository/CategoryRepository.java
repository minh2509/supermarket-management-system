package com.supermarket.supermarket.repository;

import com.supermarket.supermarket.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CategoryRepository extends JpaRepository<Category, Integer> {
}
