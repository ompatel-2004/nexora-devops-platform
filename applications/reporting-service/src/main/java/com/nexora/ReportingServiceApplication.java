package com.nexora;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;

@SpringBootApplication
@RestController
public class ReportingServiceApplication {

    @Autowired(required = false)
    private DataSource dataSource;

    public static void main(String[] args) {
        SpringApplication.run(ReportingServiceApplication.class, args);
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> resp = new HashMap<>();
        resp.put("service", "reporting-service");
        resp.put("version", "1.4.2");

        if (dataSource == null) {
            resp.put("status", "DOWN");
            resp.put("database", "DataSource unconfigured");
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(resp);
        }

        try (Connection conn = dataSource.getConnection()) {
            if (conn.isValid(2)) {
                resp.put("status", "UP");
                resp.put("database", "connected");
                return ResponseEntity.ok(resp);
            } else {
                resp.put("status", "DOWN");
                resp.put("database", "Connection probe timed out");
                return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(resp);
            }
        } catch (Exception e) {
            resp.put("status", "DOWN");
            resp.put("database", "disconnected: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(resp);
        }
    }

    @GetMapping("/reports/inventory-summary")
    public ResponseEntity<Map<String, Object>> inventorySummary() {
        if (dataSource == null) {
            Map<String, Object> err = new HashMap<>();
            err.put("error", "Database connection unavailable");
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(err);
        }

        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement()) {
            
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*), COALESCE(SUM(price * quantity), 0), COUNT(*) FILTER (WHERE available = true) FROM products;");
            if (rs.next()) {
                Map<String, Object> report = new HashMap<>();
                report.put("total_products", rs.getInt(1));
                report.put("total_valuation", rs.getDouble(2));
                report.put("in_stock_products", rs.getInt(3));
                report.put("generated_at", java.time.Instant.now().toString());
                return ResponseEntity.ok(report);
            } else {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("error", "Empty query result set"));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("error", "Query execution failed: " + e.getMessage()));
        }
    }
}
