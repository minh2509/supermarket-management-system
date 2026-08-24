package com.supermarket.supermarket.service.impl;

import com.supermarket.supermarket.dto.request.CloseShiftRequest;
import com.supermarket.supermarket.dto.request.OpenShiftRequest;
import com.supermarket.supermarket.dto.response.ShiftResponse;
import com.supermarket.supermarket.entity.Shift;
import com.supermarket.supermarket.entity.User;
import com.supermarket.supermarket.repository.SalesOrderRepository;
import com.supermarket.supermarket.repository.ShiftRepository;
import com.supermarket.supermarket.repository.UserRepository;
import com.supermarket.supermarket.service.ShiftService;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class ShiftServiceImpl implements ShiftService {

    private static final String OPEN = "OPEN";
    private static final String CLOSED = "CLOSED";

    private final ShiftRepository shiftRepository;
    private final SalesOrderRepository salesOrderRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public ShiftResponse openShift(OpenShiftRequest request) {
        User user = userRepository.findById(request.getUserId())
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Employee not found"));

        shiftRepository.findFirstByUser_IdAndStatusIgnoreCaseOrderByOpenTimeDesc(request.getUserId(), OPEN)
            .ifPresent(shift -> {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "This employee already has an open shift");
            });

        LocalDateTime now = LocalDateTime.now();
        Shift shift = Shift.builder()
            .user(user)
            .salesPoint(normalizeSalesPoint(request.getSalesPoint()))
            .openTime(now)
            .initialCash(request.getInitialCash())
            .status(OPEN)
            .createdAt(now)
            .updatedAt(now)
            .build();
        return toResponse(shiftRepository.save(shift));
    }

    @Override
    @Transactional(readOnly = true)
    public ShiftResponse getCurrentShift(Integer userId) {
        return toResponse(findOpenShift(userId));
    }

    @Override
    @Transactional
    public ShiftResponse closeCurrentShift(Integer userId, CloseShiftRequest request) {
        Shift shift = findOpenShift(userId);
        LocalDateTime now = LocalDateTime.now();
        shift.setTotalCashEnd(request.getTotalCashEnd());
        shift.setCloseTime(now);
        shift.setStatus(CLOSED);
        shift.setUpdatedAt(now);
        return toResponse(shiftRepository.save(shift));
    }

    @Override
    @Transactional(readOnly = true)
    public List<ShiftResponse> getShiftHistory(Integer userId) {
        if (!userRepository.existsById(userId)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Employee not found");
        }
        return shiftRepository.findTop30ByUser_IdOrderByOpenTimeDesc(userId)
            .stream()
            .map(this::toResponse)
            .toList();
    }

    private Shift findOpenShift(Integer userId) {
        return shiftRepository.findFirstByUser_IdAndStatusIgnoreCaseOrderByOpenTimeDesc(userId, OPEN)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No open shift found"));
    }

    private ShiftResponse toResponse(Shift shift) {
        BigDecimal initialCash = orZero(shift.getInitialCash());
        BigDecimal cashRevenue = orZero(salesOrderRepository.sumCashRevenueByShiftId(shift.getId()));
        BigDecimal revenue = orZero(salesOrderRepository.sumRevenueByShiftId(shift.getId()));
        BigDecimal systemCashEnd = initialCash.add(cashRevenue);
        BigDecimal actualCash = shift.getTotalCashEnd();
        BigDecimal difference = actualCash == null ? null : actualCash.subtract(systemCashEnd);

        User user = shift.getUser();
        String employeeName = user == null || user.getFullname() == null || user.getFullname().isBlank()
            ? (user == null ? "—" : user.getUsername())
            : user.getFullname();

        return ShiftResponse.builder()
            .id(shift.getId())
            .userId(user == null ? null : user.getId())
            .employeeName(employeeName)
            .salesPoint(shift.getSalesPoint())
            .openTime(shift.getOpenTime())
            .closeTime(shift.getCloseTime())
            .initialCash(initialCash)
            .cashRevenue(cashRevenue)
            .revenue(revenue)
            .systemCashEnd(systemCashEnd)
            .totalCashEnd(actualCash)
            .difference(difference)
            .orderCount(salesOrderRepository.countByShift_Id(shift.getId()))
            .status(shift.getStatus())
            .build();
    }

    private String normalizeSalesPoint(String salesPoint) {
        return salesPoint == null || salesPoint.isBlank() ? "Main Store" : salesPoint.trim();
    }

    private BigDecimal orZero(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }
}
