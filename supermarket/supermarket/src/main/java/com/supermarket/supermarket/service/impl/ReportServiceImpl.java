package com.supermarket.supermarket.service.impl;

import com.supermarket.supermarket.dto.response.RevenueReportItemResponse;
import com.supermarket.supermarket.repository.SalesOrderRepository;
import com.supermarket.supermarket.service.ReportService;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ReportServiceImpl implements ReportService {

    private final SalesOrderRepository salesOrderRepository;

    private static final String[] MONTH_LABELS = {
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    };

    @Override
    public List<RevenueReportItemResponse> getRevenueReport(Integer year, Integer month) {
        int resolvedYear = (year == null) ? LocalDate.now().getYear() : year;

        if (month != null) {
            return getReportByDay(resolvedYear, month);
        } else {
            return getReportByMonth(resolvedYear);
        }
    }

    private List<RevenueReportItemResponse> getReportByMonth(int year) {
        List<Object[]> rows = salesOrderRepository.revenueByMonthInYear(year);
        Map<Integer, Object[]> byMonth = new HashMap<>();
        for (Object[] row : rows) {
            int m = ((Number) row[0]).intValue();
            byMonth.put(m, row);
        }

        List<RevenueReportItemResponse> result = new ArrayList<>();
        for (int m = 1; m <= 12; m++) {
            Object[] row = byMonth.get(m);
            BigDecimal revenue = row != null ? (BigDecimal) row[1] : BigDecimal.ZERO;
            long count = row != null ? ((Number) row[2]).longValue() : 0L;
            result.add(RevenueReportItemResponse.builder()
                .label(MONTH_LABELS[m - 1])
                .totalRevenue(revenue != null ? revenue : BigDecimal.ZERO)
                .orderCount(count)
                .build());
        }
        return result;
    }

    private List<RevenueReportItemResponse> getReportByDay(int year, int month) {
        List<Object[]> rows = salesOrderRepository.revenueByDayInMonth(year, month);
        Map<Integer, Object[]> byDay = new HashMap<>();
        for (Object[] row : rows) {
            int d = ((Number) row[0]).intValue();
            byDay.put(d, row);
        }

        int daysInMonth = YearMonth.of(year, month).lengthOfMonth();
        List<RevenueReportItemResponse> result = new ArrayList<>();
        for (int d = 1; d <= daysInMonth; d++) {
            Object[] row = byDay.get(d);
            BigDecimal revenue = row != null ? (BigDecimal) row[1] : BigDecimal.ZERO;
            long count = row != null ? ((Number) row[2]).longValue() : 0L;
            result.add(RevenueReportItemResponse.builder()
                .label(String.format("%02d", d))
                .totalRevenue(revenue != null ? revenue : BigDecimal.ZERO)
                .orderCount(count)
                .build());
        }
        return result;
    }
}
