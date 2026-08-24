package com.supermarket.supermarket.repository;

import com.supermarket.supermarket.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CustomerRepository extends JpaRepository<Customer, Integer> {

    List<Customer> findAllByOrderByNameAsc();

    List<Customer> findAllByOrderByIdAsc();

    Optional<Customer> findByPhone(String phone);

    boolean existsByPhoneAndIdNot(String phone, Integer id);
}
