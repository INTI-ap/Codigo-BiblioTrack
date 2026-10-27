# BiblioTrack · Código base — Tema A

**SIS048 – Desarrollo de Software II · Evaluación Práctica de la Unidad II · Semestre 2026-II**
Universidad Andina del Cusco · Ciclo VII

Proyecto Flutter de una biblioteca personal (catálogo de libros y préstamos) que se entrega
**con errores intencionales y métodos sin implementar**. No es una aplicación terminada: es el
punto de partida de la evaluación de 60 minutos.

> **Regla de oro:** el archivo `test/bibliotrack_test.dart` está completo y **no se modifica**.
> Si se altera, se anula el criterio de pruebas de la rúbrica.

---

## Requisitos

| Herramienta | Versión verificada |
|---|---|
| Flutter | 3.41.1 (stable) |
| Dart | 3.11.0 |
| drift | 2.34.4 |
| flutter_riverpod | 2.6.1 |
| get_it | 7.7.0 |
| dartz | 0.10.1 |

Las versiones quedan fijadas en `pubspec.lock`, que se incluye para que el proyecto resuelva
igual en cualquier máquina del laboratorio.

## Puesta en marcha

```bash
flutter pub get
dart run build_runner build          # genera lib/core/database/app_database.g.dart
flutter analyze
flutter test test/bibliotrack_test.dart -v
```

El ZIP **no incluye** `app_database.g.dart` a propósito: debe generarse después de corregir el
esquema. Si se compila con un archivo generado viejo, las claves foráneas corregidas no llegan a
la base.

## Qué está incompleto

| Archivo | Estado |
|---|---|
| `lib/core/database/app_database.dart` | 7 marcadores `// ❌ ERROR N`: **6 reales y 1 falso positivo** (ERROR 1) |
| `lib/features/books/domain/entities/book_entity.dart` | `// TODO A` a `// TODO E`: reglas de negocio |
| `lib/features/books/data/repositories/book_repository_impl.dart` | `// TODO F` a `// TODO I`: validaciones, `Either` y escritura en cascada |
| `lib/features/books/presentation/controllers/books_controller.dart` | `// TODO J` a `// TODO O`: providers y controllers |
| `lib/core/di/injection_container.dart` | `// TODO P`: registro de `LoanRepository` |
| `lib/features/books/presentation/pages/books_page.dart` | `// TODO Q` y `// TODO R`: filtro y contador |
| `lib/features/books/presentation/pages/loans_page.dart` | `// TODO S`: devolución de un préstamo |

Los archivos `book_card.dart`, `genre_filter.dart`, `add_book_dialog.dart` y el diálogo de alta de
préstamo están completos: son andamiaje de interfaz, no forman parte del ejercicio.

## Resultado esperado

```text
00:00 +19: All tests passed!
```

## Entrega

`ApellidoNombre_TemaA_SIS048_2026-II.zip`, con `lib/`, `test/` y `pubspec.yaml`. Sin `build/` ni
`.dart_tool/`.

## Integridad del ejercicio

`CHECKSUMS.txt` contiene el SHA-256 del archivo de pruebas y del `pubspec.yaml`. Si el hash del
test no coincide con el entregado, el docente aplica el criterio transversal correspondiente.
