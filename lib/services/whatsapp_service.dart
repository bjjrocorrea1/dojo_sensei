import 'package:url_launcher/url_launcher.dart';

class WhatsappService {
  static Future<void> enviarComprovantePresenca({
    required String telefone,
    required String nomeAluno,
    required String nomeAcademia,
    required DateTime dataTreino,
    required String tipoTreino,
  }) async {
    final numeroLimpo = telefone.replaceAll(RegExp(r'[^0-9]'), '');
    
    final dataFormatada = "${dataTreino.day.toString().padLeft(2, '0')}/${dataTreino.month.toString().padLeft(2, '0')}/${dataTreino.year}";
    final horaFormatada = "${dataTreino.hour.toString().padLeft(2, '0')}:${dataTreino.minute.toString().padLeft(2, '0')}";

    final mensagem = Uri.encodeComponent(
      "🥋 *COMPROVANTE DE TREINO - $nomeAcademia*\n\n"
      "Olá, *$nomeAluno*!\n"
      "Presença confirmada no tatame!\n\n"
      "📅 Data: $dataFormatada\n"
      "⏰ Horário: $horaFormatada\n"
      "🎯 Tipo: $tipoTreino\n\n"
      "Oss! Continue firme nos treinos!"
    );

    final url = Uri.parse("https://wa.me/55$numeroLimpo?text=$mensagem");
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> enviarRelatorioMensal({
    required String telefone,
    required String nomeAluno,
    required String nomeAcademia,
    required int mes,
    required int ano,
    required int totalPresencas,
    required double porcentagemFrequencia,
    required String faixaAtual,
    required bool aptoParaExame,
  }) async {
    final numeroLimpo = telefone.replaceAll(RegExp(r'[^0-9]'), '');

    final statusExame = aptoParaExame 
        ? "⭐ *APTO PARA O EXAME DE FAIXA! Parabéns!*" 
        : "📈 Continue treinando para atingir os requisitos da próxima faixa.";

    final mensagem = Uri.encodeComponent(
      "📊 *RELATÓRIO MENSAL DE FREQUÊNCIA - $nomeAcademia*\n\n"
      "Aluno(a): *$nomeAluno*\n"
      "Faixa Atual: $faixaAtual\n"
      "Período: $mes/$ano\n\n"
      "✅ Total de Treinos: $totalPresencas\n"
      "📉 Taxa de Frequência: ${porcentagemFrequencia.toStringAsFixed(1)}%\n\n"
      "$statusExame\n\n"
      "Oss!"
    );

    final url = Uri.parse("https://wa.me/55$numeroLimpo?text=$mensagem");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}