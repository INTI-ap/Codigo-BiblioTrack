// lib/features/books/domain/entities/book_entity.dart
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

  // -- Reglas de negocio --

  /// TODO A: Retorna true si el libro fue publicado hace mas de 50 anos.
  bool get isClassic => DateTime.now().year - year > 50;

  /// TODO B: Retorna "Disponible" si available es true, "Prestado" si es false.
  String get statusLabel => available ? 'Disponible' : 'Prestado';

  /// TODO C: Retorna el ano como texto con prefijo "Ano: ". Ejemplo: "Ano: 1984"
  String get yearLabel => 'Año: $year';

  @override
  List<Object?> get props =>
      [id, title, author, isbn, year, genre, available, addedAt];
}

// -------------------------------------------------
// LoanEntity - entidad de prestamo
// -------------------------------------------------
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

  // -- Reglas de negocio --

  /// TODO D: Retorna true si el prestamo esta activo y la fecha limite ya paso.
  bool get isOverdue =>
      status == 'active' && dueDate != null && dueDate!.isBefore(DateTime.now());

  /// TODO E: Retorna true si el prestamo ya fue devuelto (returnDate no es null).
  bool get isReturned => returnDate != null;

  @override
  List<Object?> get props =>
      [id, bookId, borrower, loanDate, dueDate, returnDate, status];
}
