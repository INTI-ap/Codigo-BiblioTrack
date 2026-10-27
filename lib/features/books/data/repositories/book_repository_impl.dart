// lib/features/books/data/repositories/book_repository_impl.dart
//
// ══════════════════════════════════════════════════════
//  ⚠️  IMPLEMENTACIÓN INCOMPLETA — completar los TODO
// ══════════════════════════════════════════════════════
import 'package:dartz/dartz.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/book_repository.dart';
import '../models/book_model.dart';

class BookRepositoryImpl implements BookRepository {
  final BooksDao _booksDao;

  BookRepositoryImpl(this._booksDao);

  @override
  Stream<List<BookEntity>> watchAllBooks() =>
      _booksDao.watchAllBooks().map((rows) => rows.map(BookModel.fromDrift).toList());

  @override
  Stream<List<BookEntity>> watchAvailableBooks() =>
      _booksDao.watchAvailableBooks().map((rows) => rows.map(BookModel.fromDrift).toList());

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
    // TODO F: Validar que title y author no estén vacíos.
    //         Si alguno está vacío retornar:
    //         Left(ValidationFailure('Título y autor son obligatorios'))
    //         Si la validación pasa, insertar con _booksDao.insertBook(...)
    //         y retornar Right(BookModel.fromDrift(...))
    throw UnimplementedError('TODO F: implementar addBook con validación');
  }

  @override
  Future<Either<Failure, void>> updateBook(int id, {
    String? title, String? author, String? isbn, int? year, String? genre,
  }) async {
    // TODO G: Llamar _booksDao.updateBook(id, BooksCompanion(...)) con los
    //         campos que no sean null usando Value(x) y los null como Value.absent().
    //         Retornar Right(null) o Left(DatabaseFailure).
    throw UnimplementedError('TODO G: implementar updateBook');
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
  final LoansDao  _loansDao;
  final BooksDao  _booksDao;

  LoanRepositoryImpl(this._loansDao, this._booksDao);

  @override
  Stream<List<LoanEntity>> watchAllLoans() =>
      _loansDao.watchAllLoans().map((rows) => rows.map(LoanModel.fromDrift).toList());

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
    // TODO H: 1. Validar que borrower no esté vacío.
    //         2. Insertar préstamo con _loansDao.insertLoan(...)
    //         3. Marcar el libro como NO disponible: _booksDao.setAvailability(bookId, false)
    //         4. Retornar Right(LoanModel.fromDrift(nuevo préstamo))
    throw UnimplementedError('TODO H: implementar createLoan');
  }

  @override
  Future<Either<Failure, void>> returnBook(int loanId, int bookId) async {
    // TODO I: 1. Llamar _loansDao.returnLoan(loanId)
    //         2. Marcar el libro como disponible: _booksDao.setAvailability(bookId, true)
    //         3. Retornar Right(null) o Left(DatabaseFailure)
    throw UnimplementedError('TODO I: implementar returnBook');
  }
}
