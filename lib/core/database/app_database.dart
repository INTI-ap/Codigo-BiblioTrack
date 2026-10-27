// lib/core/database/app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// -------------------------------------------------
// TABLA: books  (libros del catalogo personal)
// -------------------------------------------------
class Books extends Table {
  IntColumn  get id        => integer().autoIncrement()();
  TextColumn get title     => text().withLength(min: 1, max: 200)();
  TextColumn get author    => text()();
  TextColumn get isbn      => text().nullable()();
  IntColumn  get year      => integer().withDefault(const Constant(2000))();
  TextColumn get genre     => text().withDefault(const Constant('General'))();
  BoolColumn get available => boolean().withDefault(const Constant(true))(); // CORRECTO: ya termina en ()()
  IntColumn  get addedAt   => integer().named('added_at')();
}

// -------------------------------------------------
// TABLA: loans  (prestamos de libros)
// -------------------------------------------------
class Loans extends Table {
  IntColumn  get id         => integer().autoIncrement()();
  IntColumn  get bookId     => integer().named('book_id').references(Books, #id)(); // CORREGIDO ERROR 2: clave foranea
  TextColumn get borrower   => text()();
  IntColumn  get loanDate   => integer().named('loan_date')();
  IntColumn  get dueDate    => integer().named('due_date').nullable()();
  IntColumn  get returnDate => integer().named('return_date').nullable()();
  TextColumn get status     => text().withDefault(const Constant('active'))(); // 'active' | 'returned' | 'overdue'
}

// -------------------------------------------------
// DAO: BooksDao
// -------------------------------------------------
@DriftAccessor(tables: [Books])
class BooksDao extends DatabaseAccessor<AppDatabase> with _$BooksDaoMixin {
  BooksDao(super.db);

  // Obtener todos los libros
  Future<List<Book>> getAllBooks() => select(books).get();

  // Stream reactivo de todos los libros
  Stream<List<Book>> watchAllBooks() => select(books).watch();

  // Stream filtrado por disponibilidad
  Stream<List<Book>> watchAvailableBooks() =>
      (select(books)..where((b) => b.available.equals(true))).watch();

  // CORREGIDO ERROR 3: filtra correctamente por genero
  Future<List<Book>> getByGenre(String genre) =>
      (select(books)..where((b) => b.genre.equals(genre))).get();

  // Insertar libro
  Future<int> insertBook(BooksCompanion book) =>
      into(books).insert(book);

  // CORREGIDO ERROR 4: actualiza los datos del libro y retorna true si hubo cambio
  Future<bool> updateBook(int id, BooksCompanion data) async {
    final rows = await (update(books)..where((b) => b.id.equals(id))).write(data);
    return rows > 0;
  }

  // Marcar como disponible o no disponible
  Future<void> setAvailability(int id, bool available) async {
    await (update(books)..where((b) => b.id.equals(id)))
        .write(BooksCompanion(available: Value(available)));
  }

  // CORREGIDO ERROR 5: elimina el libro con el id dado
  Future<int> deleteBook(int id) {
    return (delete(books)..where((b) => b.id.equals(id))).go();
  }
}

// -------------------------------------------------
// DAO: LoansDao
// -------------------------------------------------
@DriftAccessor(tables: [Loans])
class LoansDao extends DatabaseAccessor<AppDatabase> with _$LoansDaoMixin {
  LoansDao(super.db);

  // Stream de todos los prestamos
  Stream<List<Loan>> watchAllLoans() => select(loans).watch();

  // Prestamos activos
  Future<List<Loan>> getActiveLoans() =>
      (select(loans)..where((l) => l.status.equals('active'))).get();

  // CORREGIDO ERROR 6: filtra por bookId, no por status
  Future<List<Loan>> getLoansByBook(int bookId) =>
      (select(loans)..where((l) => l.bookId.equals(bookId))).get();

  // Registrar prestamo
  Future<int> insertLoan(LoansCompanion loan) =>
      into(loans).insert(loan);

  // CORREGIDO ERROR 7: cambia status a 'returned' Y guarda la fecha de devolucion
  Future<void> returnLoan(int loanId) async {
    await (update(loans)..where((l) => l.id.equals(loanId)))
        .write(LoansCompanion(
          status: const Value('returned'),
          returnDate: Value(DateTime.now().millisecondsSinceEpoch),
        ));
  }
}

// -------------------------------------------------
// AppDatabase
// -------------------------------------------------
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
