import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerVentasScreen extends StatefulWidget {
  const VerVentasScreen({super.key});

  @override
  State<VerVentasScreen> createState() => _VerVentasScreenState();
}

class _VerVentasScreenState extends State<VerVentasScreen> {
  String filtro = '';

  final ventasRef = FirebaseFirestore.instance
      .collection('ventas')
      .orderBy('fecha', descending: true);

  String simboloMoneda(String moneda) {
    return moneda == 'LOC' ? 'C\$' : '\$';
  }

  Future<void> anularVenta(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Anular venta?'),
        content: const Text('Esto marcará la venta como anulada.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Anular')),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('ventas').doc(id).update({
        'anulada': true,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Venta anulada')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Historial de Ventas'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 209, 212, 226),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (value) => setState(() => filtro = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: '🔍 Buscar por IMEI, tienda o factura',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ventasRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay ventas registradas.'));
          }

          final ventas = snapshot.data!.docs.where((doc) {
            final venta = doc.data() as Map<String, dynamic>;
            return venta['imei'].toString().toLowerCase().contains(filtro) ||
                venta['factura'].toString().toLowerCase().contains(filtro) ||
                venta['tienda'].toString().toLowerCase().contains(filtro);
          }).toList();

          return ListView.builder(
            itemCount: ventas.length,
            itemBuilder: (context, index) {
              final doc = ventas[index];
              final venta = doc.data() as Map<String, dynamic>;
              final fecha = venta['fecha']?.toDate()?.toString().substring(0, 16) ?? '';
              final anulada = venta['anulada'] == true;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: anulada ? Colors.grey.shade300 : null,
                child: ListTile(
                  title: Text(
                    'IMEI: ${venta['imei']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Factura: ${venta['factura']}'),
                      Text('Tienda: ${venta['tienda']}'),
                      Text('Precio: ${simboloMoneda(venta['moneda'])} ${venta['precio']}'),
                      Text('Fecha: $fecha'),
                      if (anulada) const Text('❌ Anulada', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                  trailing: anulada
                      ? null
                      : PopupMenuButton(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Text('❌ Anular'),
                              onTap: () => Future.delayed(
                                const Duration(milliseconds: 100),
                                () => anularVenta(doc.id),
                              ),
                            ),
                          ],
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
