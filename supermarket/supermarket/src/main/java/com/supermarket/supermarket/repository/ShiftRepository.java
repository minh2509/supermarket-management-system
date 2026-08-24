package com.supermarket.supermarket.repository;

import com.supermarket.supermarket.entity.Shift;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ShiftRepository extends JpaRepository<Shift, Integer> {
    Optional<Shift> findFirstByUser_IdAndStatusIgnoreCaseOrderByOpenTimeDesc(Integer userId, String status);

    List<Shift> findTop7ByUser_IdOrderByOpenTimeDesc(Integer userId);

    List<Shift> findTop30ByUser_IdOrderByOpenTimeDesc(Integer userId);
}
