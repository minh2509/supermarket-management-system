package com.supermarket.supermarket.service;

import com.supermarket.supermarket.dto.response.RevenueReportItemResponse;
import java.util.List;

public interface ReportService {
    List<RevenueReportItemResponse> getRevenueReport(Integer year, Integer month);
}
