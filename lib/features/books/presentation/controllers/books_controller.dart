// lib/features/books/presentation/controllers/books_controller.dart
//
// ══════════════════════════════════════════════════════
//  ⚠️  IMPLEMENTACIÓN PARCIAL — completar los TODO
// ══════════════════════════════════════════════════════
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/repositories/book_repository.dart';
import '../../../../core/di/injection_container.dart';

// ── Provider: filtro de género activo ─────────────────
final selectedGenreProvider = StateProvider<String?>((ref) => null);

// ── Provider: lista filtrada por género ───────────────
// TODO J: Implementar filteredBooksProvider
//   - Observar booksStreamProvider y selectedGenreProvider
//   - Si genre == null → retornar todos
//   - Si genre != null → filtrar donde book.genre == genre
//   - Propagar loading/error sin modificar
final filteredBooksProvider = Provider<AsyncValue<List<BookEntity>>>((ref) {
  // TODO: implementar — actualmente devuelve todos sin filtrar
  return ref.watch(booksStreamProvider);
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
// TODO K: Implementar availableCountProvider (Provider<int>)
//   Derivado de availableBooksProvider.
//   Usa ref.watch(...).valueOrNull?.length ?? 0

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
    // TODO L: Llamar sl<BookRepository>().addBook(...)
    //         Si es Right → actualizar state con AsyncValue.data(nueva lista)
    //         Si es Left  → lanzar Exception(failure.message)
    throw UnimplementedError('TODO L: implementar addBook en controller');
  }

  Future<void> deleteBook(int id) async {
    // TODO M: Llamar sl<BookRepository>().deleteBook(id)
    //         Manejar Right/Left igual que addBook
    throw UnimplementedError('TODO M: implementar deleteBook en controller');
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

  // TODO N: Implementar createLoan(int bookId, String borrower, DateTime? dueDate)
  //         Llamar sl<LoanRepository>().createLoan(...)
  //         Manejar Right/Left (Right → refrescar el estado, Left → throw Exception)
  Future<void> createLoan({
    required int bookId,
    required String borrower,
    DateTime? dueDate,
  }) async {
    throw UnimplementedError('TODO N: implementar createLoan en LoansController');
  }

  // TODO O: Implementar returnBook(int loanId, int bookId)
  //         Llamar sl<LoanRepository>().returnBook(loanId, bookId)
  Future<void> returnBook(int loanId, int bookId) async {
    throw UnimplementedError('TODO O: implementar returnBook en LoansController');
  }
}

final loansControllerProvider =
    AsyncNotifierProvider<LoansController, List<LoanEntity>>(
  LoansController.new,
);
