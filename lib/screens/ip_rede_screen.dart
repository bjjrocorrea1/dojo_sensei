import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';

class IpRedeScreen extends StatefulWidget {
  const IpRedeScreen({super.key});

  @override
  State<IpRedeScreen> createState() => _IpRedeScreenState();
}

class _IpRedeScreenState extends State<IpRedeScreen> {
  String _ipLocal = 'Buscando IP...';
  late String _pinSeguranca;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pinSeguranca = (1000 + Random().nextInt(9000)).toString();
    _descobrirIP();
  }

  Future<void> _descobrirIP() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          // Filtra para pegar o IPv4 local padrão (ignora loopback)
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            setState(() {
              _ipLocal = addr.address;
              _isLoading = false;
            });
            return;
          }
        }
      }
      setState(() {
        _ipLocal = 'Não foi possível detectar (Verifique o Wi-Fi)';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _ipLocal = 'Erro ao buscar IP';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conexão por Rede Local / Roteador'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.wifi_tethering, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Acesse de outro celular ou tablet conectado ao mesmo Wi-Fi ou Roteador',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const Text('Endereço IP do Aparelho Principal:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          'http://$_ipLocal:8080',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                  const SizedBox(height: 16),
                  const Text('PIN de Segurança:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    _pinSeguranca,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red[800], letterSpacing: 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '💡 Dica: Se estiver sem internet, ative o "Roteador Wi-Fi" (Hotspot) deste tablet, conecte o celular nele e digite o IP exibido acima no navegador do celular para lançar presenças!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}