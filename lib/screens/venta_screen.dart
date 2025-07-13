import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'ver_ventas_screen.dart';

class VentaScreen extends StatefulWidget {
  const VentaScreen({super.key});

  @override
  State<VentaScreen> createState() => _VentaScreenState();
}

class _VentaScreenState extends State<VentaScreen> {
  final _formKey = GlobalKey<FormState>();

  final imeiController = TextEditingController();
  final facturaController = TextEditingController();
  final tiendaController = TextEditingController();
  final precioController = TextEditingController();
  String moneda = 'LOC';

  final firestore = FirebaseFirestore.instance;

  void guardarVenta() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await firestore.collection('ventas').add({
        'imei': imeiController.text.trim(),
        'factura': facturaController.text.trim(),
        'tienda': tiendaController.text.trim(),
        'precio': double.tryParse(precioController.text.trim()) ?? 0.0,
        'moneda': moneda,
        'fecha': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Venta guardada')),
      );

      imeiController.clear();
      facturaController.clear();
      tiendaController.clear();
      precioController.clear();
      setState(() => moneda = 'LOC');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Center(
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        '📋 Información de la Venta',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // IMEI
                    TextFormField(
                      controller: imeiController,
                      decoration: const InputDecoration(
                        labelText: 'IMEI',
                        prefixIcon: Icon(Icons.confirmation_number),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 15,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(15),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El IMEI es obligatorio';
                        }
                        if (value.trim().length != 15) {
                          return 'Debe tener exactamente 15 dígitos';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 10),

                    // Factura
                    TextFormField(
                      controller: facturaController,
                      decoration: const InputDecoration(
                        labelText: 'Factura',
                        prefixIcon: Icon(Icons.receipt_long),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Tienda
                    TextFormField(
                      controller: tiendaController,
                      decoration: const InputDecoration(
                        labelText: 'Tienda / Puesto de Venta',
                        prefixIcon: Icon(Icons.store),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Precio
                    TextFormField(
                      controller: precioController,
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 10),

                    // Moneda
                    DropdownButtonFormField<String>(
                      value: moneda,
                      items: const [
                        DropdownMenuItem(value: 'LOC', child: Text('Local')),
                        DropdownMenuItem(value: 'USD', child: Text('Dólar')),
                      ],
                      onChanged: (value) {
                        setState(() => moneda = value!);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Moneda',
                        prefixIcon: Icon(Icons.monetization_on),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Botón guardar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: guardarVenta,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Botón ver historial
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const VerVentasScreen()),
                          );
                        },
                        icon: const Icon(Icons.history),
                        label: const Text('Ver historial de ventas'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}