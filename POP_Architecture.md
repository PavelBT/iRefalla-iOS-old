# Guía de Implementación: Arquitectura Orientada a Protocolos (POP)

Este documento describe el paradigma de Programación Orientada a Protocolos (POP) utilizado en este proyecto. El objetivo es proporcionar una guía clara y replicable para implementar esta arquitectura en cualquier proyecto iOS, favoreciendo la composición sobre la herencia para lograr un código más modular, testable y reutilizable.

## 1. Filosofía del Paradigma

En lugar de depender de profundas jerarquías de herencia (ej. `BaseViewController` -> `BaseTableViewController` -> `MyListViewController`), utilizamos **Protocolos** y **Extensiones de Protocolo** para "inyectar" funcionalidades específicas a cualquier clase.

**Principios Clave:**
*   **Composición > Herencia:** Las vistas se componen de múltiples comportamientos definidos por protocolos.
*   **Mix-ins:** Las extensiones de protocolo proveen implementaciones por defecto, actuando como "Mix-ins" que agregan funcionalidad inmediata.
*   **Desacoplamiento:** Los protocolos no deben depender de clases base concretas si no es estrictamente necesario.

---

## 2. Patrones de Diseño Implementados

### A. Patrón "Data Manager" (Gestor de Datos)

Este patrón abstrae la capa de red y persistencia. Cualquier objeto que necesite interactuar con el backend debe conformar a este protocolo.

**Definición del Protocolo:**
```swift
protocol DataManagerProtocol {
    // Definir métodos estáticos o de instancia para CRUD
    static func getAll() async throws -> [Self]
    static func getById(id: String) async throws -> Self?
}
```

**Implementación Genérica (Mix-in):**
Utilizamos extensiones para proveer la lógica común (ej. llamadas a Parse, Firebase, o API REST).

```swift
extension DataManagerProtocol {
    static func getAll() async throws -> [Self] {
        // Lógica genérica de petición de red
        // Retorna un array de 'Self'
    }
}
```

### B. Patrón "View Controller Mix-in" (Funcionalidad de Vista)

En lugar de heredar de un `UITableViewController`, hacemos que cualquier `UIViewController` pueda comportarse como una lista cargable conformando a un protocolo.

**Requisitos:**
El protocolo define qué necesita la vista para funcionar (ej. una `tableView` y un `array` de datos).

```swift
protocol ListDisplayable: AnyObject {
    associatedtype DataType
    
    var tableView: UITableView! { get }
    var dataArray: [DataType]? { get set }
    
    func loadData()
}
```

**Poder de la Extensión:**
La extensión conecta los puntos. Si el controlador tiene los datos y la tabla, la extensión sabe cómo recargarlos.

```swift
extension ListDisplayable {
    func loadDataAsync<T: DataManagerProtocol>(type: T.Type) {
        Task {
            do {
                let data = try await T.getAll() // Usa el patrón Data Manager
                await MainActor.run {
                    self.dataArray = data as? [DataType]
                    self.tableView.reloadData()
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
}
```

### C. Patrón "Searchable" (Búsqueda Modular)

La funcionalidad de búsqueda se extrae a su propio protocolo, permitiendo añadir una barra de búsqueda a cualquier vista sin duplicar código de delegados.

```swift
protocol Searchable: UISearchBarDelegate {
    var searchController: UISearchController { get }
    func filterContent(for text: String)
}

extension Searchable where Self: UIViewController {
    func setupSearchBar() {
        // Configuración boilerplate del SearchController
        navigationItem.searchController = searchController
    }
}
```

---

## 3. Guía de Implementación Paso a Paso

Para replicar esta arquitectura en un nuevo proyecto:

### Paso 1: Definir Protocolos Base
Crea protocolos para tus modelos de datos que incluyan la capacidad de decodificarse (ej. `JsonToObjectProtocol`) y de comunicarse con la API (ej. `NetworkManagerProtocol`).

### Paso 2: Crear Extensiones con Lógica "Default"
Implementa la lógica "pesada" (parseo JSON, peticiones HTTP) en las extensiones de estos protocolos. Usa `Result` o `async/await` para manejar asincronía limpiamente.

### Paso 3: Definir Protocolos de UI
Identifica comportamientos comunes en tus VCs:
*   ¿Tiene una tabla? -> `TableViewProtocol`
*   ¿Tiene búsqueda? -> `SearchableProtocol`
*   ¿Muestra alertas? -> `AlertableProtocol`

### Paso 4: Conformar en los View Controllers
En tus View Controllers, simplemente declara conformidad.

```swift
class MyUsersViewController: UIViewController, ListDisplayable, Searchable {
    @IBOutlet weak var tableView: UITableView!
    var dataArray: [User]?
    var searchController = UISearchController()
    
    func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar() // Viene gratis por Searchable
        loadDataAsync(type: User.self) // Viene gratis por ListDisplayable
    }
    
    // Solo implementas lo específico de esta vista (ej. cellForRowAt)
}
```

---

## 4. Ventajas de esta Arquitectura

1.  **Escalabilidad:** Añadir nuevas funcionalidades globales es tan fácil como crear un nuevo protocolo.
2.  **Mantenimiento:** La lógica de red y UI común está centralizada en las extensiones, no dispersa en herencia.
3.  **Modernización:** Facilita la adopción de nuevas tecnologías (como `async/await`) actualizando solo las extensiones del protocolo.
