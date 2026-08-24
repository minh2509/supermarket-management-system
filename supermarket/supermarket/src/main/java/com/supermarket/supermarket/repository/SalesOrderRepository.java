package com.supermarket.supermarket.repository;

import com.supermarket.supermarket.entity.SalesOrder;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface SalesOrderRepository extends JpaRepository<SalesOrder, Integer> {
    List<SalesOrder> findAllByOrderByCreatedAtDescIdDesc();

    List<SalesOrder> findByCustomer_IdOrderByCreatedAtDesc(Integer customerId);

    // Today's orders
    List<SalesOrder> findByOrderDateOrderByCreatedAtDesc(LocalDate orderDate);

    long countByShift_Id(Integer shiftId);

    @Query("SELECT COALESCE(SUM(o.totalPayable), 0) FROM SalesOrder o WHERE o.shift.id = :shiftId")
    BigDecimal sumRevenueByShiftId(@Param("shiftId") Integer shiftId);

    @Query("SELECT COALESCE(SUM(o.totalPayable), 0) FROM SalesOrder o WHERE o.shift.id = :shiftId AND UPPER(o.paymentMethod) = 'CASH'")
    BigDecimal sumCashRevenueByShiftId(@Param("shiftId") Integer shiftId);

    // Count today's orders
    long countByOrderDate(LocalDate orderDate);

    // Sum of totalPayable for a date range
    @Query("SELECT COALESCE(SUM(o.totalPayable), 0) FROM SalesOrder o WHERE o.orderDate >= :from AND o.orderDate <= :to")
    BigDecimal sumTotalPayableBetween(@Param("from") LocalDate from, @Param("to") LocalDate to);

    // Sum of totalPayable for a specific month/year
    @Query("SELECT COALESCE(SUM(o.totalPayable), 0) FROM SalesOrder o WHERE YEAR(o.orderDate) = :year AND MONTH(o.orderDate) = :month")
    BigDecimal sumTotalPayableByYearAndMonth(@Param("year") int year, @Param("month") int month);

    // Count orders for a specific month/year
    @Query("SELECT COUNT(o) FROM SalesOrder o WHERE YEAR(o.orderDate) = :year AND MONTH(o.orderDate) = :month")
    long countByYearAndMonth(@Param("year") int year, @Param("month") int month);

    // Sum of totalPayable for a specific year
    @Query("SELECT COALESCE(SUM(o.totalPayable), 0) FROM SalesOrder o WHERE YEAR(o.orderDate) = :year")
    BigDecimal sumTotalPayableByYear(@Param("year") int year);

    // Count all orders in a specific year
    @Query("SELECT COUNT(o) FROM SalesOrder o WHERE YEAR(o.orderDate) = :year")
    long countByYear(@Param("year") int year);

    // Revenue per day in a given month (for report)
    @Query("SELECT DAY(o.orderDate) as day, COALESCE(SUM(o.totalPayable), 0) as revenue, COUNT(o) as cnt " +
           "FROM SalesOrder o WHERE YEAR(o.orderDate) = :year AND MONTH(o.orderDate) = :month " +
           "GROUP BY DAY(o.orderDate) ORDER BY DAY(o.orderDate)")
    List<Object[]> revenueByDayInMonth(@Param("year") int year, @Param("month") int month);

    // Revenue per month in a given year (for report)
    @Query("SELECT MONTH(o.orderDate) as month, COALESCE(SUM(o.totalPayable), 0) as revenue, COUNT(o) as cnt " +
           "FROM SalesOrder o WHERE YEAR(o.orderDate) = :year " +
           "GROUP BY MONTH(o.orderDate) ORDER BY MONTH(o.orderDate)")
    List<Object[]> revenueByMonthInYear(@Param("year") int year);
}
