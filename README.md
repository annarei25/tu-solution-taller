# Tu Solution

Aplicación Android para la gestión de reparaciones del taller **Tu Solution**. Permite recibir equipos, asignarlos a técnicos, registrar trabajos y repuestos, controlar el inventario y consultar el historial de cada equipo.

Proyecto para el **Segundo Examen Parcial** de la asignatura *Programación para Dispositivos Móviles*, Ingeniería Informática, 3er año.

> **Datos de prueba:** al abrir la app por primera vez, se cargan datos iniciales de prueba: 3 técnicos, repuestos de ejemplo y 2 equipos con sus órdenes. Están pensados para que la app se pueda revisar de inmediato. Ver la sección [Datos de prueba](#datos-de-prueba) para saber cómo quitarlos.

---

## Funcionalidades

- **Selección de técnico:** al abrir la app, el técnico elige su perfil. Puede cambiarlo más tarde desde la pestaña Técnicos.
- **Órdenes de reparación:** lista de órdenes abiertas con filtros por técnico y por «sin asignar».
- **Tomar una orden:** solo un técnico puede tener una orden a la vez. Si otro ya la tomó, la app lo avisa.
- **Detalle de orden:** trabajos con mano de obra, repuestos usados, liquidación con el total y cambio de estado (recibida, en reparación, lista, entregada o cancelada).
- **Técnicos:** carga de trabajo de cada técnico. El taller siempre tiene exactamente 3 técnicos activos; para cambiar uno se da de baja y se registra su reemplazo.
- **Inventario:** repuestos por categoría, búsqueda por nombre o código, creación y edición de repuestos, entradas de stock y alerta de repuestos por agotarse.
- **Historial:** búsqueda de equipos por número de serie, modelo o cliente, con su bitácora completa. Desde ahí se puede abrir una orden nueva para el mismo equipo.

La app **funciona sin internet** y conserva los datos aunque se cierre.

---

## Requisitos

- Flutter estable (versión 3.24 o superior).
- Dart 3.5 o superior (viene incluido con Flutter).
- Android Studio o VS Code con la extensión de Flutter.
- Un teléfono Android con **depuración USB** activa, o un emulador de Android.

Para comprobar la instalación:

```bash
flutter doctor
```

Todos los elementos de Android deben aparecer con una marca verde.

---

## Instalación y ejecución

Estos pasos se hacen **una sola vez**, desde la carpeta del proyecto.

### 1. Clonar el repositorio

```bash
git clone https://github.com/annarei25/tu_solution.git
cd tu_solution
```

### 2. Instalar las dependencias

```bash
flutter pub get
```

### 3. Generar el código de la base de datos

El proyecto usa Drift, que genera automáticamente algunos archivos (`*.g.dart`). Esos archivos no se suben al repositorio, así que **este paso es obligatorio** antes de compilar:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Si este comando no se ejecuta, el proyecto muestra errores de archivos que no existen.

### 4. Conectar el teléfono o abrir un emulador

Revisa que Flutter lo reconozca:

```bash
flutter devices
```

### 5. Ejecutar la aplicación

```bash
flutter run
```

La primera compilación tarda varios minutos. Las siguientes son más rápidas.

---

## Datos de prueba

Al iniciar la app, el archivo `lib/data/database/seed.dart` carga datos de prueba **solo si la tabla de técnicos está vacía**. Los datos son:

| Tipo | Contenido |
|---|---|
| Técnicos | Carlos Mendoza (Apple), Andrés Ramos (Portátiles), Mateo Peña (Multimarca) |
| Repuestos | Pantallas, baterías y puertos de carga, con algunas existencias en cero o por debajo del mínimo para mostrar la alerta |
| Equipos y órdenes | iPhone 13 Pro de Marcos Valdés (S/N `G6TF892K0`) y Samsung Galaxy S22 de Lucía Ferrer (S/N `R5CT4421AB`) |

Estos datos son ficticios. Los nombres, teléfonos y números de serie no corresponden a personas reales.

### Cómo quitar los datos de prueba

Para empezar con datos reales, sigue estos pasos:

1. Abre `lib/app/app.dart` y busca la línea `cargarDatosDePrueba(ref.read(databaseProvider));` dentro de `initState`.
2. Coméntala o bórrala.
3. Desinstala la app del teléfono, o borra sus datos desde *Ajustes → Aplicaciones → Tu Solution → Almacenamiento → Borrar datos*.

Si solo quieres reiniciar los datos de prueba, borra los datos de la app en el teléfono y vuelve a abrirla.

---

## Cómo usar la aplicación

1. **Elige el técnico** que usa el teléfono.
2. En **Órdenes**, toca **Tomar orden** para asignarte una orden libre. Solo el técnico responsable puede editarla.
3. En el **detalle**, agrega trabajos y repuestos, y cambia el estado cuando avance la reparación.
4. Con el botón central **Nueva**, registra un equipo que llega al taller. Si el número de serie ya existe, la orden se asocia al equipo registrado.
5. En **Inventario**, crea repuestos, edita precios o registra entradas de stock.
6. En **Historial**, busca un equipo para ver todas sus visitas.

Para cambiar de técnico, usa **Técnicos → Cambiar de técnico**.

---

## Capturas de pantalla

<!-- Reemplaza estas rutas por las capturas reales del proyecto -->

| Órdenes | Detalle de orden | Técnicos | Inventario | Historial |
|---|---|---|---|---|
| ![Órdenes](docs/capturas/ordenes.png) | ![Detalle](docs/capturas/detalle.png) | ![Técnicos](docs/capturas/tecnicos.png) | ![Inventario](docs/capturas/inventario.png) | ![Historial](docs/capturas/historial.png) |

---

## Estructura del proyecto

```
lib/
├── main.dart              arranque de la app
├── app/                   MaterialApp, tema y barra inferior
├── core/                  enums, utilidades y widgets compartidos
├── data/
│   ├── database/          base de datos, tablas, DAOs y datos de prueba
│   └── repositories/      reglas del taller
├── providers/             providers globales de Riverpod
└── features/
    ├── sesion/            selección de técnico
    ├── ordenes/           lista y detalle de órdenes
    ├── nueva_orden/       recepción de equipos
    ├── tecnicos/          carga de trabajo y gestión
    ├── inventario/        repuestos y entradas de stock
    └── historial/         búsqueda y bitácora de equipos
```

Cada feature tiene tres carpetas: `viewmodels/` (estado y acciones), `views/` (pantallas) y `widgets/` (piezas propias de la pantalla).

---

## Tecnologías

| Paquete | Uso |
|---|---|
| Flutter y Dart | Interfaz y lenguaje |
| drift, drift_flutter | Base de datos SQLite tipada |
| flutter_riverpod | Gestión de estado |
| flutter_lucide | Íconos |
| shared_preferences | Guardar el técnico activo |
| path_provider | Ruta de la base de datos en el teléfono |
| intl | Formato de fechas (instalado para uso futuro) |

La arquitectura sigue **MVVM**: las pantallas solo muestran datos y envían eventos; los ViewModels guardan el estado y las acciones; los repositorios aplican las reglas del taller y los DAOs ejecutan las consultas.

---

## Problemas frecuentes

**El proyecto no compila y aparecen errores en archivos `*.g.dart`.**
Ejecuta `dart run build_runner build --delete-conflicting-outputs`.

**`flutter pub get` falla con un error 403 o de permisos.**
La red bloquea pub.dev. Prueba con otra red, por ejemplo el hotspot del teléfono.

**La app se queda cargando y no muestra nada.**
Revisa la terminal de `flutter run`. Si aparece un error al abrir la base, borra los datos de la app en el teléfono y vuelve a ejecutar.

**Cambié una tabla y la app falla al abrirse.**
Sube `schemaVersion` en `app_database.dart` y agrega la migración correspondiente. Si es un cambio grande y no hay datos importantes, desinstala la app y vuelve a instalarla.

---

## Limitaciones conocidas

- No hay autenticación. Cualquier persona con acceso al teléfono puede usar la app, como indica el enunciado.
- La app no envía mensajes ni notificaciones a los clientes.
- Los datos quedan únicamente en el teléfono donde se usa la app. No hay sincronización entre dispositivos.

---

## Autora

**Ana Laura Reinoso Fernandez** · Ingeniería Informática, 3er año