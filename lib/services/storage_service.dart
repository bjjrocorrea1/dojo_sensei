import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/aluno_model.dart';
import '../models/presenca_model.dart';
import '../models/tecnica_midia_model.dart';
import '../models/modalidade_config_model.dart';

class StorageService {
  static const String _keyAlunos = 'alunos_list';
  static const String _keyPresencas = 'presencas_list';
  static const String _keyMidias = 'midias_list';
  static const String _keyConfig = 'config_academia';
  static const String _keySenhaAdmin = 'senha_admin';

  // --- SENHA DO ADMIN ---
  Future<String> getSenhaAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySenhaAdmin) ?? '1234'; // Padrão 1234
  }

  Future<void> setSenhaAdmin(String novaSenha) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySenhaAdmin, novaSenha);
  }

// --- AUTENTICAÇÃO DE ALUNO (SEGURA) ---
  Future<Aluno?> autenticarAluno(String nome, String senha) async {
    final alunos = await getAlunos();
    try {
      return alunos.firstWhere(
        (a) => a.nome.toLowerCase() == nome.toLowerCase() && a.senha == senha,
      );
    } catch (_) {
      return null;
    }
  }

  // --- GESTÃO DE ALUNOS ---
  Future<List<Aluno>> getAlunos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_keyAlunos);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Aluno.fromJson(json)).toList();
  }

  Future<void> saveAluno(Aluno aluno) async {
    final alunos = await getAlunos();
    final index = alunos.indexWhere((a) => a.id == aluno.id);
    if (index >= 0) {
      alunos[index] = aluno;
    } else {
      alunos.add(aluno);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAlunos, jsonEncode(alunos.map((a) => a.toJson()).toList()));
  }

  Future<void> deleteAluno(String id) async {
    final alunos = await getAlunos();
    alunos.removeWhere((a) => a.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAlunos, jsonEncode(alunos.map((a) => a.toJson()).toList()));
  }

  // --- GESTÃO DE PRESENÇAS ---
  Future<List<Presenca>> getPresencas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_keyPresencas);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Presenca.fromJson(json)).toList();
  }

  Future<void> savePresenca(Presenca presenca) async {
    final presencas = await getPresencas();
    presencas.add(presenca);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPresencas, jsonEncode(presencas.map((p) => p.toJson()).toList()));
  }
  
  // Atalho para compatibilidade com a tela de presença
  Future<void> registrarPresenca(Presenca presenca) async {
    await savePresenca(presenca);
  }

  // --- LIMPAR PRESENÇAS (APENAS ADMIN) ---
  Future<void> limparTodasPresencas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPresencas);
  }

  // --- GESTÃO DE MÍDIAS (VÍDEOS E PDFS) ---
  Future<List<TecnicaMidia>> getMidias() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_keyMidias);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => TecnicaMidia.fromJson(json)).toList();
  }

  Future<void> saveMidia(TecnicaMidia midia) async {
    final midias = await getMidias();
    midias.add(midia);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMidias, jsonEncode(midias.map((m) => m.toJson()).toList()));
  }

  // --- CONFIGURAÇÃO DA ACADEMIA ---
  Future<ConfiguracaoAcademia> getConfiguracao() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_keyConfig);
    if (data == null) {
      return ConfiguracaoAcademia(
        nomeAcademia: 'Dojo Sensei',
        modalidade: 'Jiu-Jitsu',
        logoUrl: '',
        faixas: ConfiguracaoAcademia.obterFaixasPadrao('Jiu-Jitsu'),
      );
    }
    return ConfiguracaoAcademia.fromJson(jsonDecode(data));
  }

  Future<void> saveConfiguracao(ConfiguracaoAcademia config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyConfig, jsonEncode(config.toJson()));
  }
}