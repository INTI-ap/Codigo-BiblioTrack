// lib/features/books/data/repositories/book_repository_impl.dart
//
// ══════════════════════════════════════════════════════
//  Repositorios: validaciones y persistencia con Either
// ══════════════════════════════════════════════════════
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/book_repository.dart';
import '../models/book_model.dart';

class BookRepositoryImpl implements BookRepository {
  final BooksDao _booksDao;

  BookRepositoryImpl(this._booksDao);

  @override
  Stream<List<BookEntity>> watchAllBooks() => _booksDao
      .watchAllBooks()
      .map((rows) => rows.map(BookModel.fromDrift).toList());

  @override
  Stream<List<BookEntity>> watchAvailableBooks() => _booksDao
      .watchAvailableBooks()
      .map((rows) => rows.map(BookModel.fromDrift).toList());

  @override
  Future<Either<Failure, List<BookEntity>>> getByGenre(String genre) async {
    try {
      final rows = await _booksDao.getByGenre(genre);
      return Right(rows.map(BookModel.fromDrift).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookEntity>> addBook({
    required String title,
    required String author,
    String? isbn,
    required int year,
    required String genre,
  }) async {
    // Valida los campos obligatorios antes de guardar.
    if (title.trim().isEmpty || author.trim().isEmpty) {
      return const Left(ValidationFailure('Título y autor son obligatorios'));
    }
    try {
      final id = await _booksDao.insertBook(BooksCompanion.insert(
        title: title.trim(),
        author: author.trim(),
        isbn: Value(isbn),
        year: Value(year),
        genre: Value(genre),
        addedAt: DateTime.now().millisecondsSinceEpoch,
      ));
      final row = (await _booksDao.getAllBooks()).firstWhere((b) => b.id == id);
      return Right(BookModel.fromDrift(row));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBook(
    int id, {
    String? title,
    String? author,
    String? isbn,
    int? year,
    String? genre,
  }) async {
    // Los campos nulos conservan su valor actual.
    try {
      await _booksDao.updateBook(
          id,
          BooksCompanion(
            title: title == null ? const Value.absent() : Value(title),
            author: author == null ? const Value.absent() : Value(author),
            isbn: isbn == null ? const Value.absent() : Value(isbn),
            year: year == null ? const Value.absent() : Value(year),
            genre: genre == null ? const Value.absent() : Value(genre),
          ));
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBook(int id) async {
    try {
      await _booksDao.deleteBook(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}

// ─────────────────────────────────────────────────────
// LoanRepositoryImpl
// ─────────────────────────────────────────────────────
class LoanRepositoryImpl implements LoanRepository {
  final LoansDao _loansDao;
  final BooksDao _booksDao;

  LoanRepositoryImpl(this._loansDao, this._booksDao);

  @override
  Stream<List<LoanEntity>> watchAllLoans() => _loansDao
      .watchAllLoans()
      .map((rows) => rows.map(LoanModel.fromDrift).toList());

  @override
  Future<Either<Failure, List<LoanEntity>>> getActiveLoans() async {
    try {
      final rows = await _loansDao.getActiveLoans();
      return Right(rows.map(LoanModel.fromDrift).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LoanEntity>> createLoan({
    required int bookId,
    required String borrower,
    DateTime? dueDate,
  }) async {
    if (borrower.trim().isEmpty) {
      return const Left(
          ValidationFailure('El nombre del prestatario es obligatorio'));
    }
    try {
      // Guarda el prestamo y la disponibilidad en una misma transaccion.
      return await _loansDao.attachedDatabase.transaction(() async {
        final id = await _loansDao.insertLoan(LoansCompanion.insert(
          bookId: bookId,
          borrower: borrower.trim(),
          loanDate: DateTime.now().millisecondsSinceEpoch,
          dueDate: Value(dueDate?.millisecondsSinceEpoch),
        ));
        await _booksDao.setAvailability(bookId, false);
        final row = (await _loansDao.getLoansByBook(bookId))
            .firstWhere((l) => l.id == id);
        return Right<Failure, LoanEntity>(LoanModel.fromDrift(row));
      });
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> returnBook(int loanId, int bookId) async {
    try {
      // La devolucion tambien vuelve a habilitar el libro.
      await _loansDao.attachedDatabase.transaction(() async {
        await _loansDao.returnLoan(loanId);
        await _booksDao.setAvailability(bookId, true);
      });
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
