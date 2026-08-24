package com.supermarket.supermarket.service.impl;

import com.supermarket.supermarket.dto.request.CreateOrderRequest;
import com.supermarket.supermarket.dto.response.CheckoutOrderResponse;
import com.supermarket.supermarket.dto.response.DashboardSummaryResponse;
import com.supermarket.supermarket.dto.response.DashboardTransactionResponse;
import com.supermarket.supermarket.dto.response.OrderDetailItemResponse;
import com.supermarket.supermarket.dto.response.OrderDetailResponse;
import com.supermarket.supermarket.dto.response.OrderListItemResponse;
import com.supermarket.supermarket.entity.Customer;
import com.supermarket.supermarket.entity.Discount;
import com.supermarket.supermarket.entity.OrderItem;
import com.supermarket.supermarket.entity.Product;
import com.supermarket.supermarket.entity.SalesOrder;
import com.supermarket.supermarket.entity.Shift;
import com.supermarket.supermarket.entity.User;
import com.supermarket.supermarket.repository.CustomerRepository;
import com.supermarket.supermarket.repository.DiscountRepository;
import com.supermarket.supermarket.repository.OrderItemRepository;
import com.supermarket.supermarket.repository.ProductRepository;
import com.supermarket.supermarket.repository.SalesOrderRepository;
import com.supermarket.supermarket.repository.ShiftRepository;
import com.supermarket.supermarket.repository.SupplierRepository;
import com.supermarket.supermarket.repository.UserRepository;
import com.supermarket.supermarket.service.OrderService;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {
    private static final DateTimeFormatter ORDER_DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");

    private final SalesOrderRepository salesOrderRepository;
    private final OrderItemRepository orderItemRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;
    private final SupplierRepository supplierRepository;
    private final CustomerRepository customerRepository;
    private final DiscountRepository discountRepository;
    private final ShiftRepository shiftRepository;

    @Override
    public List<OrderListItemResponse> getAllOrders() {
        return salesOrderRepository.findAllByOrderByCreatedAtDescIdDesc()
            .stream()
            .map(this::toResponse)
            .toList();
    }

    @Override
    public List<OrderListItemResponse> getOrdersByCustomerId(Integer customerId) {
        return salesOrderRepository.findByCustomer_IdOrderByCreatedAtDesc(customerId)
            .stream()
            .map(this::toResponse)
            .toList();
    }

    @Override
    public OrderDetailResponse getOrderDetail(Integer orderId) {
        SalesOrder order = salesOrderRepository.findById(orderId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Order not found"));

        List<OrderDetailItemResponse> items = orderItemRepository.findByOrder_IdOrderByIdAsc(orderId)
            .stream()
            .map(this::toDetailItem)
            .toList();

        return OrderDetailResponse.builder()
            .id(order.getId())
            .orderNo(emptyAsDash(order.getOrderNo()))
            .customerPhone(emptyAsDash(order.getCustomerPhone()))
            .cashierName(resolveCashierName(order))
            .subtotal(orZero(order.getSubtotal()))
            .discountPercent(orZero(order.getDiscountPercent()))
            .discountAmount(orZero(order.getDiscountAmount()))
            .totalPayment(orZero(order.getTotalPayable()))
            .items(items)
            .build();
    }

    @Override
    public DashboardSummaryResponse getDashboardSummary() {
        LocalDate today = LocalDate.now();
        LocalDate firstDayOfMonth = today.withDayOfMonth(1);
        LocalDate firstDayOfYear = today.withDayOfYear(1);
        LocalDate threeMonthsAgo = today.minusMonths(3).withDayOfMonth(1);
        LocalDate sixMonthsAgo = today.minusMonths(6).withDayOfMonth(1);

        BigDecimal todaySales = salesOrderRepository.sumTotalPayableBetween(today, today);
        long todayInvoiceCount = salesOrderRepository.countByOrderDate(today);
        BigDecimal currentMonthSales = salesOrderRepository.sumTotalPayableBetween(firstDayOfMonth, today);
        BigDecimal last3MonthSales = salesOrderRepository.sumTotalPayableBetween(threeMonthsAgo, today);
        BigDecimal last6MonthSales = salesOrderRepository.sumTotalPayableBetween(sixMonthsAgo, today);
        BigDecimal currentYearRevenue = salesOrderRepository.sumTotalPayableBetween(firstDayOfYear, today);
        long invoiceCount = salesOrderRepository.countByYear(today.getYear());
        long userCount = userRepository.count();

        // New data from repositories
        long supplierCount = supplierRepository.count();
        long availableProductsCount = productRepository.countByInStockGreaterThan(0);
        long expiredProducts = productRepository.countByExpiryDateBefore(today);
        long newProductsCount = productRepository.countByCreatedAtAfter(today.minusDays(7).atStartOfDay());

        // Top Selling Products
        List<DashboardSummaryResponse.TopProductResponse> topProducts = orderItemRepository
            .findTopSellingProducts(PageRequest.of(0, 5))
            .stream()
            .map(obj -> DashboardSummaryResponse.TopProductResponse.builder()
                .name((String) obj[0])
                .totalQty(((Number) obj[1]).longValue())
                .build())
            .toList();

        return DashboardSummaryResponse.builder()
            .todaySales(orZero(todaySales))
            .expiredProducts(expiredProducts)
            .todayInvoiceCount(todayInvoiceCount)
            .newProductsCount(newProductsCount)
            .supplierCount(supplierCount)
            .invoiceCount(invoiceCount)
            .currentMonthSales(orZero(currentMonthSales))
            .last3MonthSales(orZero(last3MonthSales))
            .last6MonthSales(orZero(last6MonthSales))
            .userCount(userCount)
            .availableProductsCount(availableProductsCount)
            .currentYearRevenue(orZero(currentYearRevenue))
            .topProducts(topProducts)
            .build();
    }

    @Override
    public List<DashboardTransactionResponse> getTodayTransactions() {
        LocalDate today = LocalDate.now();
        return salesOrderRepository.findByOrderDateOrderByCreatedAtDesc(today)
            .stream()
            .map(o -> DashboardTransactionResponse.builder()
                .orderNo(emptyAsDash(o.getOrderNo()))
                .paymentMethod(emptyAsDash(o.getPaymentMethod()))
                .totalPayable(orZero(o.getTotalPayable()))
                .cashierName(resolveCashierName(o))
                .status(emptyAsDash(o.getStatus()))
                .createdAt(o.getCreatedAt())
                .build())
            .toList();
    }

    @Override
    @Transactional
    public CheckoutOrderResponse createOrder(CreateOrderRequest request) {
        User cashier = userRepository.findById(request.getCashierId())
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Cashier not found"));

        Shift activeShift = shiftRepository
            .findFirstByUser_IdAndStatusIgnoreCaseOrderByOpenTimeDesc(request.getCashierId(), "OPEN")
            .orElseThrow(() -> new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Please open a shift before creating a transaction"
            ));

        LocalDateTime now = LocalDateTime.now();
        String normalizedPhone = normalizePhone(request.getCustomerPhone());
        Customer customer = null;
        if (!normalizedPhone.isBlank()) {
            customer = customerRepository.findAllByOrderByIdAsc()
                .stream()
                .filter(c -> normalizePhone(c.getPhone()).equals(normalizedPhone))
                .findFirst()
                .orElse(null);
        }

        Discount discount = null;
        if (request.getDiscountId() != null) {
            discount = discountRepository.findById(request.getDiscountId())
                .orElse(null);
        }

        List<OrderItem> pendingItems = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;
        for (CreateOrderRequest.CreateOrderItemRequest itemReq : request.getItems()) {
            BigDecimal kg = itemReq.getKg() == null ? BigDecimal.ONE : itemReq.getKg();
            if (kg.compareTo(BigDecimal.ZERO) <= 0) {
                continue;
            }
            Product product = productRepository.findById(itemReq.getProductId())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Product not found: " + itemReq.getProductId()));
            int inStock = Objects.requireNonNullElse(product.getInStock(), 0);
            int qty = itemReq.getQty();
            if (qty > inStock) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Insufficient stock for product: " + product.getProductName());
            }

            BigDecimal unitPrice = orZero(product.getSellingPrice());
            BigDecimal lineAmount = unitPrice.multiply(BigDecimal.valueOf(qty)).multiply(kg);
            subtotal = subtotal.add(lineAmount);

            pendingItems.add(OrderItem.builder()
                .product(product)
                .productName(product.getProductName())
                .unitPrice(unitPrice)
                .qty(qty)
                .amount(lineAmount)
                .build());

            product.setInStock(inStock - qty);
            product.setUpdatedAt(now);
            productRepository.save(product);
        }
        if (pendingItems.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "No billable items. Enter Kg > 0.");
        }

        BigDecimal discountPercent = request.getDiscountPercent() == null
            ? BigDecimal.ZERO
            : request.getDiscountPercent();
        if (discountPercent.compareTo(BigDecimal.ZERO) < 0) {
            discountPercent = BigDecimal.ZERO;
        }
        if (discountPercent.compareTo(BigDecimal.valueOf(100)) > 0) {
            discountPercent = BigDecimal.valueOf(100);
        }

        BigDecimal discountAmount = subtotal.multiply(discountPercent).divide(BigDecimal.valueOf(100));
        BigDecimal totalPayable = subtotal.subtract(discountAmount);
        BigDecimal paid = orZero(request.getPaid());
        BigDecimal outstandingBalance = totalPayable.subtract(paid).max(BigDecimal.ZERO);
        BigDecimal changeAmount = paid.subtract(totalPayable).max(BigDecimal.ZERO);

        String orderNo = "INV-" + now.format(DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss-SSS"));
        SalesOrder order = SalesOrder.builder()
            .orderNo(orderNo)
            .customer(customer)
            .customerPhone((request.getCustomerPhone() == null || request.getCustomerPhone().isBlank())
                ? (customer == null ? null : customer.getPhone())
                : request.getCustomerPhone().trim())
            .customerName((request.getCustomerName() == null || request.getCustomerName().isBlank())
                ? (customer == null ? null : customer.getName())
                : request.getCustomerName().trim())
            .cashier(cashier)
            .shift(activeShift)
            .salesPoint((request.getSalesPoint() == null || request.getSalesPoint().isBlank()) ? "Main Store" : request.getSalesPoint().trim())
            .orderDate(now.toLocalDate())
            .orderTime(LocalTime.of(now.getHour(), now.getMinute(), now.getSecond()))
            .subtotal(subtotal)
            .discount(discount)
            .discountPercent(discountPercent)
            .discountAmount(discountAmount)
            .totalPayable(totalPayable)
            .paid(paid)
            .balance(outstandingBalance)
            .paymentMethod((request.getPaymentMethod() == null || request.getPaymentMethod().isBlank()) ? "Cash" : request.getPaymentMethod().trim())
            .status(outstandingBalance.compareTo(BigDecimal.ZERO) > 0 ? "Pending" : "Paid")
            .payDueDate(outstandingBalance.compareTo(BigDecimal.ZERO) > 0 ? now.toLocalDate().plusDays(7) : null)
            .createdAt(now)
            .updatedAt(now)
            .build();

        SalesOrder savedOrder = salesOrderRepository.save(order);

        List<CheckoutOrderResponse.CheckoutOrderItemResponse> responseItems = new ArrayList<>();
        for (OrderItem item : pendingItems) {
            item.setOrder(savedOrder);
            orderItemRepository.save(item);
            responseItems.add(CheckoutOrderResponse.CheckoutOrderItemResponse.builder()
                .productName(emptyAsDash(item.getProductName()))
                .unitPrice(orZero(item.getUnitPrice()))
                .qty(Objects.requireNonNullElse(item.getQty(), 0))
                .amount(orZero(item.getAmount()))
                .build());
        }

        if (customer != null) {
            int existingPoints = Objects.requireNonNullElse(customer.getPoints(), 0);
            int earnedPoints = totalPayable.divide(BigDecimal.valueOf(1000)).intValue();
            customer.setPoints(existingPoints + Math.max(earnedPoints, 0));
            customer.setTotalPurchases(Objects.requireNonNullElse(customer.getTotalPurchases(), 0) + 1);
            customer.setTotalAmount(orZero(customer.getTotalAmount()).add(totalPayable));
            customer.setUpdatedAt(now);
            customerRepository.save(customer);
        }

        return CheckoutOrderResponse.builder()
            .orderId(savedOrder.getId())
            .orderNo(savedOrder.getOrderNo())
            .customerName(resolveCustomerName(savedOrder))
            .customerPhone(emptyAsDash(savedOrder.getCustomerPhone()))
            .cashierName(resolveCashierName(savedOrder))
            .salesPoint(emptyAsDash(savedOrder.getSalesPoint()))
            .orderDate(savedOrder.getOrderDate() == null ? "—" : savedOrder.getOrderDate().toString())
            .orderTime(savedOrder.getOrderTime() == null ? "—" : savedOrder.getOrderTime().toString())
            .subtotal(orZero(savedOrder.getSubtotal()))
            .discountPercent(orZero(savedOrder.getDiscountPercent()))
            .discountAmount(orZero(savedOrder.getDiscountAmount()))
            .totalPayable(orZero(savedOrder.getTotalPayable()))
            .paid(orZero(savedOrder.getPaid()))
            .balance(changeAmount)
            .paymentMethod(emptyAsDash(savedOrder.getPaymentMethod()))
            .items(responseItems)
            .build();
    }

    private OrderListItemResponse toResponse(SalesOrder order) {
        return OrderListItemResponse.builder()
            .id(order.getId())
            .orderNo(emptyAsDash(order.getOrderNo()))
            .orderDateTime(resolveOrderDateTime(order))
            .customerName(resolveCustomerName(order))
            .customerPhone(emptyAsDash(order.getCustomerPhone()))
            .total(orZero(order.getSubtotal()))
            .discountPercent(orZero(order.getDiscountPercent()))
            .payable(orZero(order.getTotalPayable()))
            .paid(order.getPaid())
            .paymentMethod(emptyAsDash(order.getPaymentMethod()))
            .status(emptyAsDash(order.getStatus()))
            .cashierName(resolveCashierName(order))
            .build();
    }

    private String resolveCustomerName(SalesOrder order) {
        if (order.getCustomerName() != null && !order.getCustomerName().isBlank()) {
            return order.getCustomerName();
        }
        if (order.getCustomer() != null && order.getCustomer().getName() != null && !order.getCustomer().getName().isBlank()) {
            return order.getCustomer().getName();
        }
        return "—";
    }

    private String resolveCashierName(SalesOrder order) {
        if (order.getCashier() == null) {
            return "—";
        }
        if (order.getCashier().getFullname() != null && !order.getCashier().getFullname().isBlank()) {
            return order.getCashier().getFullname();
        }
        if (order.getCashier().getUsername() != null && !order.getCashier().getUsername().isBlank()) {
            return order.getCashier().getUsername();
        }
        return "—";
    }

    private String emptyAsDash(String value) {
        return value == null || value.isBlank() ? "—" : value;
    }

    private BigDecimal orZero(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }

    private OrderDetailItemResponse toDetailItem(OrderItem item) {
        Integer qty = Objects.requireNonNullElse(item.getQty(), 0);
        return OrderDetailItemResponse.builder()
            .productName(emptyAsDash(item.getProductName()))
            .unitPrice(orZero(item.getUnitPrice()))
            .qty(qty)
            .amount(orZero(item.getAmount()))
            .build();
    }

    private String resolveOrderDateTime(SalesOrder order) {
        LocalDateTime dateTime = null;
        if (order.getOrderDate() != null) {
            dateTime = LocalDateTime.of(
                order.getOrderDate(),
                order.getOrderTime() == null ? java.time.LocalTime.MIDNIGHT : order.getOrderTime()
            );
        } else if (order.getCreatedAt() != null) {
            dateTime = order.getCreatedAt();
        }
        if (dateTime == null) {
            return "—";
        }
        return ORDER_DATE_TIME_FORMATTER.format(dateTime);
    }

    private String normalizePhone(String phone) {
        if (phone == null) {
            return "";
        }
        return phone.replaceAll("[^0-9]", "");
    }
}
