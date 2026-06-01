package com.example.tests;  // Ajustar al paquete del proyecto

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.TestInfo;
import org.mockito.MockitoAnnotations;

import java.util.logging.Logger;

/**
 * Clase base para todos los tests del proyecto.
 * Extiende esta clase en tus TestCase para heredar
 * la configuración común de Mockito y logging.
 *
 * Uso:
 *   class UsuarioServiceTest extends TestBase { ... }
 */
public abstract class TestBase {

    protected static final Logger log = Logger.getLogger(TestBase.class.getName());

    private AutoCloseable mockitoCloseable;

    @BeforeEach
    void initMocks(TestInfo testInfo) {
        mockitoCloseable = MockitoAnnotations.openMocks(this);
        log.fine(() -> "Iniciando: " + testInfo.getDisplayName());
    }

    @AfterEach
    void closeMocks(TestInfo testInfo) throws Exception {
        mockitoCloseable.close();
        log.fine(() -> "Finalizado: " + testInfo.getDisplayName());
    }

    // ── Helpers de assertion ─────────────────────────────────────────────────

    /**
     * Verifica que dos doubles son iguales dentro de un margen de error.
     * Útil para comparaciones de precios y cálculos financieros.
     */
    protected static void assertDecimalEquals(double expected, double actual) {
        org.junit.jupiter.api.Assertions.assertEquals(expected, actual, 0.001,
            () -> String.format("Esperado: %.3f, Actual: %.3f", expected, actual));
    }

    // ── Datos de prueba comunes ──────────────────────────────────────────────
    // Sobrescribe en subclases o añade aquí fixtures globales del proyecto.

    // protected Usuario usuarioValido() {
    //     return new Usuario(1L, "Ana García", "ana@example.com");
    // }
}
