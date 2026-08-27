import 'package:flutter/material.dart';
import '../models/producto_model.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;

  const ProductoCard({
    super.key,
    required this.producto,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(producto.nombre),
        subtitle: Text('ID: ${producto.id}'),
        trailing: Text(
          '\$${producto.precio.toStringAsFixed(0)}',
        ),
      ),
    );
  }
}
