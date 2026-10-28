// lib/features/books/presentation/controllers/books_controller.dart
//
// ══════════════════════════════════════════════════════
//  Providers y controladores de libros y prestamos
// ══════════════════════════════════════════════════════
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/book_repository.dart';
import '../../../../core/di/injection_container.dart';

// ── Provider: filtro de género activo ─────────────────
final selectedGenreProvider = StateProvider<String?>((ref) => null);

// ── Provider: lista filtrada por género ───────────────
// Filtra los datos sin perder los estados de carga y error.
final filteredBooksProvider = Provider<AsyncValue<List<BookEntity>>>((ref) {
  final books = ref.watch(booksStreamProvider);
  final genre = ref.watch(selectedGenreProvider);
  return books.whenData((items) => genre == null
      ? items
      : items.where((book) => book.genre == genre).toList());
});

// ── StreamProvider: stream reactivo desde Drift ───────
final booksStreamProvider = StreamProvider<List<BookEntity>>((ref) {
  return sl<BookRepository>().watchAllBooks();
});

// ── StreamProvider: solo libros disponibles ───────────
final availableBooksProvider = StreamProvider<List<BookEntity>>((ref) {
  return sl<BookRepository>().watchAvailableBooks();
});

// ── Provider: conteo de libros disponibles ────────────
final availableCountProvider = Provider<int>((ref) {
  return ref.watch(availableBooksProvider).valueOrNull?.length ?? 0;
});

// ── AsyncNotifier: operaciones CRUD de libros ─────────
class BooksController extends AsyncNotifier<List<BookEntity>> {
  @override
  Future<List<BookEntity>> build() async {
    final stream = sl<BookRepository>().watchAllBooks();
    ref.onDispose(() {});
    return await stream.first;
  }

  Future<void> addBook({
    required String title,
    required String author,
    String? isbn,
    required int year,
    required String genre,
  }) async {
    final result = await sl<BookRepository>().addBook(
      title: title,
      author: author,
      isbn: isbn,
      year: year,
      genre: genre,
    );
    await result.fold<Future<void>>(
      (failure) async => throw Exception(failure.message),
      (_) async {
        state =
            AsyncValue.data(await sl<BookRepository>().watchAllBooks().first);
      },
    );
  }

  Future<void> deleteBook(int id) async {
    final result = await sl<BookRepository>().deleteBook(id);
    await result.fold<Future<void>>(
      (failure) async => throw Exception(failure.message),
      (_) async {
        state =
            AsyncValue.data(await sl<BookRepository>().watchAllBooks().first);
      },
    );
  }

  // ✅ COMPLETO — refresh forzado
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final stream = sl<BookRepository>().watchAllBooks();
      return await stream.first;
    });
  }
}

final booksControllerProvider =
    AsyncNotifierProvider<BooksController, List<BookEntity>>(
  BooksController.new,
);

// ─────────────────────────────────────────────────────
// LoansController
// ─────────────────────────────────────────────────────
final loansStreamProvider = StreamProvider<List<LoanEntity>>((ref) {
  return sl<LoanRepository>().watchAllLoans();
});

class LoansController extends AsyncNotifier<List<LoanEntity>> {
  @override
  Future<List<LoanEntity>> build() async {
    return await sl<LoanRepository>().watchAllLoans().first;
  }

  // Actualiza el estado solo cuando el repositorio confirma la operacion.
  Future<void> createLoan({
    required int bookId,
    required String borrower,
    DateTime? dueDate,
  }) async {
    final result = await sl<LoanRepository>().createLoan(
      bookId: bookId,
      borrower: borrower,
      dueDate: dueDate,
    );
    await result.fold<Future<void>>(
      (failure) async => throw Exception(failure.message),
      (_) async {
        state =
            AsyncValue.data(await sl<LoanRepository>().watchAllLoans().first);
      },
    );
  }

  Future<void> returnBook(int loanId, int bookId) async {
    final result = await sl<LoanRepository>().returnBook(loanId, bookId);
    await result.fold<Future<void>>(
      (failure) async => throw Exception(failure.message),
      (_) async {
        state =
            AsyncValue.data(await sl<LoanRepository>().watchAllLoans().first);
      },
    );
  }
}

final loansControllerProvider =
    AsyncNotifierProvider<LoansController, List<LoanEntity>>(
  LoansController.new,
);
