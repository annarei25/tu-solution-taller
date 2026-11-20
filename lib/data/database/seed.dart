import 'app_database.dart';

/// Carga datos de prueba si la base está vacía.
Future<void> cargarDatosDePrueba(AppDatabase db) async {
  final tecnicos = await db.tecnicosDao.watchTodos().first;
  if (tecnicos.isNotEmpty) return;

  await db.tecnicosDao.crear('Carlos Mendoza', especialidad: 'Apple');
  await db.tecnicosDao.crear('Andrés Ramos', especialidad: 'Portátiles');
  await db.tecnicosDao.crear('Mateo Peña', especialidad: 'Multimarca');

  await db.inventarioDao.crear(
    codigo: 'REP-IP13-SCR',
    nombre: 'Pantalla OLED iPhone 13 Pro',
    categoria: 'Pantallas',
    precio: 85,
    existencias: 2,
  );
  await db.inventarioDao.crear(
    codigo: 'REP-SAM-BAT22',
    nombre: 'Batería Samsung Galaxy S22',
    categoria: 'Baterías',
    precio: 32,
    existencias: 0,
  );
  await db.inventarioDao.crear(
    codigo: 'REP-XIA-CC11',
    nombre: 'Módulo conector USB-C Xiaomi',
    categoria: 'Puertos',
    precio: 9.5,
    existencias: 1,
  );
  await db.inventarioDao.crear(
    codigo: 'REP-APL-MACM1',
    nombre: 'Batería MacBook Air M1',
    categoria: 'Baterías',
    precio: 68,
    existencias: 5,
  );
  await db.inventarioDao.crear(
    codigo: 'REP-IPD-SCR9',
    nombre: 'Pantalla completa iPad 9na gen',
    categoria: 'Pantallas',
    precio: 55,
    existencias: 4,
  );

  await db.equiposDao.recibir(
    clienteNombre: 'Marcos Valdés',
    telefono: '555-4921',
    tipo: 'Smartphone',
    marca: 'Apple',
    modelo: 'iPhone 13 Pro',
    numeroSerie: 'G6TF892K0',
    falla: 'Pantalla rota por caída, sin imagen ni respuesta táctil',
  );
  await db.equiposDao.recibir(
    clienteNombre: 'Lucía Ferrer',
    telefono: '555-8832',
    tipo: 'Smartphone',
    marca: 'Samsung',
    modelo: 'Galaxy S22',
    numeroSerie: 'R5CT4421AB',
    falla: 'Batería inflada y recalentamiento',
  );
}
