package com.supermarket.supermarket.controller;

import com.supermarket.supermarket.dto.request.CloseShiftRequest;
import com.supermarket.supermarket.dto.request.OpenShiftRequest;
import com.supermarket.supermarket.dto.response.ShiftResponse;
import com.supermarket.supermarket.service.ShiftService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/shifts")
@RequiredArgsConstructor
public class ShiftController {

    private final ShiftService shiftService;

    @PostMapping("/open")
    public ResponseEntity<ShiftResponse> openShift(@Valid @RequestBody OpenShiftRequest request) {
        return ResponseEntity.ok(shiftService.openShift(request));
    }

    @GetMapping("/current/{userId}")
    public ResponseEntity<ShiftResponse> getCurrentShift(@PathVariable Integer userId) {
        return ResponseEntity.ok(shiftService.getCurrentShift(userId));
    }

    @PostMapping("/current/{userId}/close")
    public ResponseEntity<ShiftResponse> closeCurrentShift(
        @PathVariable Integer userId,
        @Valid @RequestBody CloseShiftRequest request
    ) {
        return ResponseEntity.ok(shiftService.closeCurrentShift(userId, request));
    }

    @GetMapping("/history/{userId}")
    public ResponseEntity<List<ShiftResponse>> getShiftHistory(@PathVariable Integer userId) {
        return ResponseEntity.ok(shiftService.getShiftHistory(userId));
    }
}
