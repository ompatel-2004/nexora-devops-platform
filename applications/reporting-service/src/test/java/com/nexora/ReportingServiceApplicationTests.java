package com.nexora;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class ReportingServiceApplicationTests {

    @Test
    void contextLoads() {
        ReportingServiceApplication app = new ReportingServiceApplication();
        assertNotNull(app.health());
    }
}
