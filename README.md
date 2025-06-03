# UalaCities App – README

## 📱 Descripción
Este proyecto es parte de una prueba técnica para la posición Mobile Engineer iOS. En el mismo se desarrolla una app de gestión de ciudades con búsqueda, favoritos y visualización en mapa. La aplicación es compatible tanto con iPad como con iPhone, usando `NavigationSplitView` para adaptarse de manera fluida a cada dispositivo. Soporta visualización en pantalla dividida en iPad.

Se utilizó SwiftData como motor de persistencia local, combinando SwiftUI, tareas asíncronas (`async/await`) y paginado eficiente para manejar una gran cantidad de datos.

## 🧠 Architecture: MVVM
Se utiliza el patrón **Model-View-ViewModel (MVVM)** para separar responsabilidades y facilitar el testeo. Esto permite:

- Reutilizar lógica de negocio en el ViewModel.
- Mantener las vistas simples y enfocadas en el renderizado.
- Aislar la lógica de red y persistencia para pruebas unitarias.

## ⚙️ Decisiones Técnicas

- Durante el desarrollo se tomaron decisiones clave para garantizar escalabilidad, performance y mantenibilidad:

- Persistencia en chunks: se implementó saveCitiesInChunks para dividir la inserción de ciudades en bloques, mejorando la eficiencia de memoria y evitando bloqueos.

- Persistencia concurrente: todas las operaciones de guardado se ejecutan con async/await para no bloquear el hilo principal y mantener la UI responsiva. El uso de `withThrowingTaskGroup` es para poder dividir la persitencia de los datos de manera concurrente para asi mejorar los tiempos de persistencia.

- Paginación de 50 elementos: se definió un límite de carga por página para evitar accesos costosos al almacenamiento persistente.

- Separación de responsabilidades: networking, persistencia y lógica de UI están completamente desacoplados.

- Mocks para UI Testing: se utiliza una bandera de ejecución para inyectar datos controlados al correr tests automatizados.

- Compatibilidad universal: la aplicación fue diseñada para adaptarse tanto a iPhone como iPad sin cambios de código, aprovechando NavigationSplitView y @Environment.

## 💉 Dependency Injection via Protocols
Se definen protocolos para los servicios que interactúan con la red y la base de datos local:

- `NetworkingServiceProtocol`
- `CityPersisterProtocol`

Estos protocolos son inyectados al `CityListViewModel` a través de un `CityListEnvironment`, lo que permite:

- Reemplazarlos por mocks en tests.
- Cambiar su implementación sin afectar al ViewModel ni a las vistas.

## 🔄 ViewState
 `ViewState` para manejar los estados de la vista principal:

```swift
enum ViewState<T> {
    case loading
    case content(T)
    case noData
    case error(message: String)
}
```

Esto mejora la claridad y control del ciclo de vida de la UI:
- `.loading` → muestra `ProgressView`
- `.content` → renderiza la lista de ciudades
- `.noData` → mensaje amigable sin resultados
- `.error` → informa al usuario con el mensaje de error

## 💾 Persistencia con SwiftData
- Guardar ciudades localmente usando `ModelContext`.
- Hacer paginación y búsquedas eficientes con `FetchDescriptor`.
- Filtrar por nombre, país o favoritos.

SwiftData fue elegida por:
- Su integración con SwiftUI.
- Soporte nativo para predicados y paginación.
- Simplicidad para configurar modelos persistentes.

## 🧪 Testing
### Unit Tests
Se testea el ViewModel con mocks de `NetworkingServiceProtocol` y `CityPersisterProtocol`. Por ejemplo:

- Filtrar ciudades por texto (vacío, una letra, coincidencia exacta).
- Mostrar favoritos.
- Paginación.
- Manejo de errores al sincronizar.

Cada test prepara su propio entorno de datos para garantizar independencia y consistencia.

### UI Tests
Tests de UI básicos con `XCTest` para:

- Mostrar todas las ciudades.
- Filtrar por favoritos.
- Tocar el botón de favorito en una una celda para modificar la seleccion de favorito respecto a una ciudad.
- Realizar busqueda y mostrar ciudades filtradas.

Se utiliza `app.launchArguments.append("UI-TESTING")` para inyectar mocks en tiempo de ejecución.

## ✅ Principios SOLID Aplicados
- **Responsabilidad Única**: `CityListViewModel` solo se encarga de orquestar lógica de UI, no de networking o persistencia.
- **Inversión de Dependencias**: trabajamos contra protocolos (`NetworkingServiceProtocol` y `CityPersisterProtocol`).
- **Abierto/Cerrado**: las implementaciones reales y de mocks pueden evolucionar sin modificar el ViewModel.

## 🧩 Modularidad
- `CityListViewModel` usa `CityListEnvironment` para acceder a dependencias.
- Cada dependencia se testea de forma aislada.

## 🚀 Performance
- Se optimiza con paginación (`fetchLimit`, `fetchOffset`).
- `saveCitiesInChunks` permite guardar en bloques para minimizar el uso de memoria.