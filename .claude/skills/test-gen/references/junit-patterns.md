# Patrones de Testing — Java / JUnit 5

## Estructura AAA (Arrange, Act, Assert)

```java
@Test
void calcularDescuento_precioValido_retornaMontoReducido() {
    // Arrange
    double precioOriginal = 100.0;
    int porcentaje = 20;
    CalculadoraDescuentos calc = new CalculadoraDescuentos();

    // Act
    double resultado = calc.aplicar(precioOriginal, porcentaje);

    // Assert
    assertEquals(80.0, resultado, 0.001);
}
```

## Nomenclatura

Formato: `<metodo>_<condicion>_<resultadoEsperado>`

```java
// Bien
void validarEmail_formatoInvalido_retornaFalse()
void crearUsuario_sinNombre_lanzaIllegalArgumentException()
void calcularTotal_listaVacia_retornaCero()

// Mal
void testEmail()
void test1()
void funciona()
```

## Anotaciones esenciales de JUnit 5

```java
import org.junit.jupiter.api.*;
import static org.junit.jupiter.api.Assertions.*;

class UsuarioServiceTest {

    private UsuarioService service;

    @BeforeEach
    void setUp() {
        service = new UsuarioService();
    }

    @AfterEach
    void tearDown() {
        // limpieza si es necesaria
    }

    @BeforeAll
    static void setUpClass() {
        // una sola vez antes de todos los tests
    }

    @Test
    void crearUsuario_datosValidos_retornaUsuarioConId() {
        Usuario usuario = new Usuario("Ana", "ana@example.com");
        Usuario resultado = service.crear(usuario);
        assertNotNull(resultado.getId());
    }

    @Test
    @DisplayName("Crear usuario sin email debe lanzar excepción")
    void crearUsuario_sinEmail_lanzaExcepcion() {
        assertThrows(IllegalArgumentException.class, () ->
            service.crear(new Usuario("Ana", null))
        );
    }
}
```

## Tests parametrizados

```java
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.*;

@ParameterizedTest
@CsvSource({
    "0,    cero",
    "1,    positivo",
    "-1,   negativo",
    "999,  positivo"
})
void clasificarNumero_variosInputs_retornaCategoriaCorrecta(int numero, String esperado) {
    assertEquals(esperado, clasificador.clasificar(numero));
}

@ParameterizedTest
@ValueSource(strings = {"", " ", "   ", "\t"})
void validarNombre_stringVacioOBlanco_retornaFalse(String nombre) {
    assertFalse(validador.esValido(nombre));
}

@ParameterizedTest
@NullSource
void validarNombre_null_retornaFalse(String nombre) {
    assertFalse(validador.esValido(nombre));
}
```

## Mockito — mocking de dependencias

```java
import org.mockito.*;
import static org.mockito.Mockito.*;
import org.junit.jupiter.api.extension.ExtendWith;

@ExtendWith(MockitoExtension.class)
class PagoServiceTest {

    @Mock
    private GatewayPago gateway;

    @InjectMocks
    private PagoService service;

    @Test
    void procesarPago_gatewayAprueba_retornaConfirmacion() {
        // Arrange
        when(gateway.cobrar(100.0, "4111...")).thenReturn(new Respuesta("OK", "TXN-001"));

        // Act
        Confirmacion resultado = service.procesar(100.0, "4111...");

        // Assert
        assertEquals("TXN-001", resultado.getTransaccionId());
        verify(gateway).cobrar(100.0, "4111...");
    }

    @Test
    void procesarPago_gatewayFalla_lanzaPaymentException() {
        when(gateway.cobrar(anyDouble(), anyString()))
            .thenThrow(new GatewayException("timeout"));

        assertThrows(PaymentException.class, () ->
            service.procesar(100.0, "4111...")
        );
    }
}
```

## Assertions avanzadas

```java
// Múltiples assertions agrupadas (todas se evalúan aunque fallen)
assertAll("datos usuario",
    () -> assertEquals("Ana", usuario.getNombre()),
    () -> assertEquals("ana@example.com", usuario.getEmail()),
    () -> assertNotNull(usuario.getId())
);

// Assertions sobre colecciones
List<String> nombres = service.obtenerNombres();
assertAll(
    () -> assertEquals(3, nombres.size()),
    () -> assertTrue(nombres.contains("Ana")),
    () -> assertFalse(nombres.isEmpty())
);

// Con mensaje de error descriptivo
assertEquals(esperado, actual, 
    () -> "El descuento calculado debería ser " + esperado + " pero fue " + actual);
```

## Testing con @Nested para organizar escenarios

```java
@Nested
@DisplayName("cuando el usuario existe")
class CuandoUsuarioExiste {

    private Usuario usuario;

    @BeforeEach
    void setUp() {
        usuario = service.crear(new Usuario("Ana", "ana@example.com"));
    }

    @Test
    void buscar_retornaUsuario() {
        assertNotNull(service.buscarPorId(usuario.getId()));
    }

    @Test
    void eliminar_reduceCantidad() {
        int cantidadAntes = service.contar();
        service.eliminar(usuario.getId());
        assertEquals(cantidadAntes - 1, service.contar());
    }
}

@Nested
@DisplayName("cuando el usuario no existe")
class CuandoUsuarioNoExiste {

    @Test
    void buscar_lanzaNotFoundException() {
        assertThrows(NotFoundException.class, () ->
            service.buscarPorId(999L)
        );
    }
}
```

## Casos borde comunes

| Tipo | Casos a testear |
|---|---|
| String | `null`, `""`, espacios, caracteres especiales |
| Lista | `null`, vacía, un elemento, muy grande |
| Número | `0`, negativo, `Integer.MAX_VALUE`, `null` (para wrappers) |
| Fecha | fecha pasada, hoy, futura, `null` |
| Objeto | `null`, objeto con campos opcionales ausentes |

## Configuración Maven (pom.xml)

```xml
<dependencies>
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <version>5.10.1</version>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.mockito</groupId>
        <artifactId>mockito-junit-jupiter</artifactId>
        <version>5.7.0</version>
        <scope>test</scope>
    </dependency>
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-surefire-plugin</artifactId>
            <version>3.2.2</version>
        </plugin>
    </plugins>
</build>
```
