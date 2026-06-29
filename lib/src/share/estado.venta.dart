enum EstadoVenta {
  OPENED, // Se está creando aún
  FINISHED, // El vendedor terminó de crear la venta
  CLOSED; // La venta ya se transfirió al otro sistema, no se puede tocar.
}

EstadoVenta estadoVentaFromApi(String? v) {
  switch (v) {
    case 'OPENED':
      return EstadoVenta.OPENED;
    case 'FINISHED':
      return EstadoVenta.FINISHED;
    case 'CLOSED':
      return EstadoVenta.CLOSED;
    default:
      return EstadoVenta.OPENED;
  }
}
