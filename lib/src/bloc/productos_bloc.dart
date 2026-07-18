import 'dart:async';

import 'package:dipalza_movil/src/model/producto_model.dart';
import 'package:dipalza_movil/src/provider/productos_provider.dart';
import 'package:dipalza_movil/src/share/cached_list_store.dart';
import 'package:rxdart/rxdart.dart';

class ProductsBloc {
  static final ProductsBloc _singleton = new ProductsBloc._internal();
  final _productsController = BehaviorSubject<List<ProductosModel>>();

  static const _ttl = Duration(minutes: 15);

  final _store = CachedListStore<ProductosModel>(
    key: 'cache_productos_list',
    toJsonString: productosModelToJson,
    fromJsonString: productosModelFromJson,
  );

  // --- 1. AÑADIMOS UN FUTURE PARA CONTROLAR LA CARGA INICIAL ---
  late Future<void> _initialLoad;

  // --- 3. LO EXPONEMOS PARA QUE OTROS LO PUEDAN 'AWAIT' ---
  Future<void> get initialLoadDone => _initialLoad;

  factory ProductsBloc() {
    return _singleton;
  }

  ProductsBloc._internal() {
    _initialLoad = ensureFresh();
  }

  // Acá deben conectarse los interesados en escuchar los productos
  Stream<List<ProductosModel>> get productsStream => _productsController.stream;

  // Obtiene el valor que recuerda _productosController.
  List<ProductosModel> get productList => _productsController.value;

  /// TTL-aware: si hay caché lo emite de inmediato; si está vencido (o no
  /// había caché), refresca desde la red en segundo plano.
  Future<void> ensureFresh() async {
    final cached = await _store.read();
    if (cached != null) {
      _productsController.sink.add(cached.items);
      if (!cached.isStale(_ttl)) return;
    }
    await _refrescarDesdeRed();
  }

  /// Bypassa el TTL: siempre refresca desde la red. Usado por pull-to-refresh.
  Future<void> forceRefresh() => _refrescarDesdeRed();

  Future<void> _refrescarDesdeRed() async {
    try {
      final lista =
          await ProductosProvider.productosProvider.obtenerListaProductos();
      _productsController.sink.add(lista);
      await _store.write(lista);
    } catch (e) {
      if (_productsController.valueOrNull == null) {
        _productsController.addError(e);
      }
    }
  }

  /// Busca y devuelve una LISTA de productos que coincidan con el término.
  List<ProductosModel> searchProducts(String termino) {
    if (termino.isEmpty) return [];

    final listaCompleta = _productsController.valueOrNull;
    if (listaCompleta == null || listaCompleta.isEmpty) return [];

    final terminoUpper = termino.toUpperCase();

    // Lógica de filtro (similar a la de productos.page.dart)
    return listaCompleta.where((producto) {
      final descMatch =
          producto.descripcion.toUpperCase().contains(terminoUpper);
      final codeMatch = producto.articulo.toUpperCase().contains(terminoUpper);
      return descMatch || codeMatch;
    }).toList();
  }

  /// Busca un producto por término (código o nombre) en la lista cacheadA.
  /// Es síncrono, por lo que es muy rápido.
  ProductosModel? searchProduct(String termino) {
    if (termino.isEmpty) return null;

    // 1. Obtiene la lista actual que tiene el BLoC
    final listaCompleta = _productsController.valueOrNull;
    if (listaCompleta == null || listaCompleta.isEmpty) return null;

    final terminoUpper = termino.toUpperCase();
    ProductosModel? productoEncontrado;

    // 2. Intenta buscar por CÓDIGO/ARTÍCULO exacto primero (es lo más probable)
    //    Esta lógica es la misma de tu ProductosPage
    try {
      productoEncontrado = listaCompleta
          .firstWhere((p) => p.articulo.toUpperCase() == terminoUpper);
      return productoEncontrado;
    } catch (e) {
      // No se encontró por código, buscar por nombre...
    }

    // 3. Si no, busca por DESCRIPCIÓN (primera coincidencia)
    try {
      productoEncontrado = listaCompleta.firstWhere(
          (p) => p.descripcion.toUpperCase().contains(terminoUpper));
      return productoEncontrado;
    } catch (e) {
      // No se encontró tampoco
      return null;
    }
  }

  /// Actualiza un producto específico dentro de la lista cacheada del BLoC.
  void updatePorduct(ProductosModel productoActualizado) {
    // 1. Obtiene la lista actual que tiene el BLoC
    final actualList = _productsController.valueOrNull;

    if (actualList == null || actualList.isEmpty) return null;
    // 2. Busca el índice del producto que queremos actualizar
    //    (Asegúrate de que tu ProductosModel tenga un 'id' o 'articulo' único)
    final index = actualList
        .indexWhere((p) => p.articulo == productoActualizado.articulo);

    // 3. Si lo encuentra, lo reemplaza
    if (index != -1) {
      actualList[index] = productoActualizado;

      // 4. Mete la lista (ya modificada) de nuevo en el stream
      //    El StreamBuilder en ProductosPage se actualizará automáticamente.
      _productsController.sink.add(actualList);
    }
  }

  dispose() {
    _productsController.close();
  }
}
