// lib/features/books/domain/entities/book_entity.dart
//
// ══════════════════════════════════════════════════════
//  ⚠️  IMPLEMENTACIÓN INCOMPLETA
//      Completa los métodos marcados con // TODO
// ══════════════════════════════════════════════════════
import 'package:equatable/equatable.dart';

class BookEntity extends Equatable {
  final int    id;
  final String title;
  final String author;
  final String? isbn;
  final int    year;
  final String genre;
  final bool   available;
  final DateTime addedAt;

  const BookEntity({
    required this.id,
    required this.title,
    required this.author,
    this.isbn,
    required this.year,
    required this.genre,
    required this.available,
    required this.addedAt,
  });

  // ── Reglas de negocio ──────────────────────────────

  /// TODO A: Retorna true si el libro fue publicado hace más de 50 años.
  /// Pista: usar DateTime.now().year - year > 50
  bool get isClassic {
    // TODO: implementar
    throw UnimplementedError();
  }

  /// TODO B: Retorna una etiqueta de estado:
  ///   - available == true  → "Disponible"
  ///   - available == false → "Prestado"
  String get statusLabel {
    // TODO: implementar
    throw UnimplementedError();
  }

  /// TODO C: Retorna el año como String con prefijo "Año: "
  /// Ejemplo: "Año: 1984"
  String get yearLabel {
    // TODO: implementar
    throw UnimplementedError();
  }

  @override
  List<Object?> get props =>
      [id, title, author, isbn, year, genre, available, addedAt];
}

// ─────────────────────────────────────────────────────
// LoanEntity — entidad de préstamo
// ─────────────────────────────────────────────────────
class LoanEntity extends Equatable {
  final int      id;
  final int      bookId;
  final String   borrower;
  final DateTime loanDate;
  final DateTime? dueDate;
  final DateTime? returnDate;
  final String   status; // 'active' | 'returned' | 'overdue'

  const LoanEntity({
    required this.id,
    required this.bookId,
    required this.borrower,
    required this.loanDate,
    this.dueDate,
    this.returnDate,
    required this.status,
  });

  // ── Reglas de negocio ──────────────────────────────

  /// TODO D: Retorna true si el préstamo está activo Y la fecha de devolución
  /// esperada (dueDate) es anterior a hoy (está vencido).
  bool get isOverdue {
    // TODO: implementar
    throw UnimplementedError();
  }

  /// TODO E: Retorna true si el préstamo ya fue devuelto (returnDate != null).
  bool get isReturned {
    // TODO: implementar
    throw UnimplementedError();
  }

  @override
  List<Object?> get props =>
      [id, bookId, borrower, loanDate, dueDate, returnDate, status];
}
