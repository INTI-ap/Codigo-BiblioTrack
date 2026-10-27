// lib/core/database/app_database.dart
//
// ══════════════════════════════════════════════════════
//  ❌  ESTE ARCHIVO CONTIENE ERRORES INTENCIONALES
//      El estudiante debe identificarlos y corregirlos.
//      Busca los comentarios marcados con: // ❌ ERROR
// ══════════════════════════════════════════════════════
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ─────────────────────────────────────────────────────
// TABLA: books  (libros del catálogo personal)
// ─────────────────────────────────────────────────────
class Books extends Table {
  IntColumn  get id       => integer().autoIncrement()();
  TextColumn get title    => text().withLength(min: 1, max: 200)();
  TextColumn get author   => text()();
  TextColumn get isbn     => text().nullable()();
  IntColumn  get year     => integer().withDefault(const Constant(2000))();
  TextColumn get genre    => text().withDefault(const Constant('General'))();
  BoolColumn get available => boolean().withDefault(const Constant(true))();  // ❌ ERROR 1: falta llamada ()() al final
  IntColumn  get addedAt  => integer().named('added_at')();
}

// ─────────────────────────────────────────────────────
// TABLA: loans  (préstamos de libros)
// ─────────────────────────────────────────────────────
class Loans extends Table {
  IntColumn  get id         => integer().autoIncrement()();
  IntColumn  get bookId     => integer().named('book_id')();  // ❌ ERROR 2: falta la referencia foránea .references(Books, #id)
  TextColumn get borrower   => text()();
  IntColumn  get loanDate   => integer().named('loan_date')();
  IntColumn  get dueDate    => integer().named('due_date').nullable()();
  IntColumn  get returnDate => integer().named('return_date').nullable()();
  TextColumn get status     => text().withDefault(const Constant('active'))(); // 'active' | 'returned' | 'overdue'
}

// ─────────────────────────────────────────────────────
// DAO: BooksDao
// ─────────────────────────────────────────────────────
@DriftAccessor(tables: [Books])
class BooksDao extends DatabaseAccessor<AppDatabase> with _$BooksDaoMixin {
  BooksDao(super.db);

  // ✅ COMPLETO — obtener todos los libros
  Future<List<Book>> getAllBooks() => select(books).get();

  // ✅ COMPLETO — stream reactivo
  Stream<List<Book>> watchAllBooks() => select(books).watch();

  // ✅ COMPLETO — stream filtrado por disponibilidad
  Stream<List<Book>> watchAvailableBooks() =>
      (select(books)..where((b) => b.available.equals(true))).watch();

  // ❌ ERROR 3: este método tiene un bug lógico — devuelve todos los libros
  // aunque se pide filtrar por género. Corregirlo.
  Future<List<Book>> getByGenre(String genre) =>
      select(books).get(); // BUG: debería filtrar por genre

  // ✅ COMPLETO — insertar libro
  Future<int> insertBook(BooksCompanion book) =>
      into(books).insert(book);

  // ❌ ERROR 4: updateBook está incompleto — no actualiza nada realmente.
  // Debe recibir un BooksCompanion y usar update() correctamente.
  Future<bool> updateBook(int id, BooksCompanion data) async {
    // BUG: no hace nada, siempre retorna false
    return false;
  }

  // ✅ COMPLETO — marcar como disponible/no disponible
  Future<void> setAvailability(int id, bool available) async {
    await (update(books)..where((b) => b.id.equals(id)))
        .write(BooksCompanion(available: Value(available)));
  }

  // ❌ ERROR 5: deleteBook no está implementado — lanza excepción.
  Future<int> deleteBook(int id) {
    throw UnimplementedError('TODO: implementar deleteBook');
  }
}

// ─────────────────────────────────────────────────────
// DAO: LoansDao
// ─────────────────────────────────────────────────────
@DriftAccessor(tables: [Loans])
class LoansDao extends DatabaseAccessor<AppDatabase> with _$LoansDaoMixin {
  LoansDao(super.db);

  // ✅ COMPLETO — stream de todos los préstamos
  Stream<List<Loan>> watchAllLoans() => select(loans).watch();

  // ✅ COMPLETO — préstamos activos
  Future<List<Loan>> getActiveLoans() =>
      (select(loans)..where((l) => l.status.equals('active'))).get();

  // ❌ ERROR 6: getLoansByBook filtra por status en lugar de bookId.
  Future<List<Loan>> getLoansByBook(int bookId) =>
      (select(loans)..where((l) => l.status.equals('active'))).get(); // BUG

  // ✅ COMPLETO — registrar préstamo
  Future<int> insertLoan(LoansCompanion loan) =>
      into(loans).insert(loan);

  // ❌ ERROR 7: returnLoan debe cambiar status a 'returned' Y guardar returnDate,
  // pero solo cambia el status. Completar.
  Future<void> returnLoan(int loanId) async {
    await (update(loans)..where((l) => l.id.equals(loanId)))
        .write(const LoansCompanion(
          status: Value('returned'),
          // BUG: falta returnDate: Value(DateTime.now().millisecondsSinceEpoch)
        ));
  }
}

// ─────────────────────────────────────────────────────
// AppDatabase
// ─────────────────────────────────────────────────────
@DriftDatabase(
  tables: [Books, Loans],
  daos:   [BooksDao, LoansDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await customStatement('PRAGMA journal_mode=WAL');
      await customStatement('PRAGMA foreign_keys=ON');
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys=ON');
    },
  );

  /// Constructor para tests (BD en memoria).
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'bibliotrack.db'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
