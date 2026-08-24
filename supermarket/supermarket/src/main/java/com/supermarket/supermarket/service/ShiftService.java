package com.supermarket.supermarket.service;

import com.supermarket.supermarket.dto.request.CloseShiftRequest;
import com.supermarket.supermarket.dto.request.OpenShiftRequest;
import com.supermarket.supermarket.dto.response.ShiftResponse;
import java.util.List;

public interface ShiftService {
    ShiftResponse openShift(OpenShiftRequest request);

    ShiftResponse getCurrentShift(Integer userId);

    ShiftResponse closeCurrentShift(Integer userId, CloseShiftRequest request);

    List<ShiftResponse> getShiftHistory(Integer userId);
}
