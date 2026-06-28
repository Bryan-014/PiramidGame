import 'package:flutter/material.dart';

import '../shared/app_design.dart';
import '../shared/widgets/app_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _criteria = [
    'Resenha',
    'Presença VIP',
    'Aura',
    'Modo Parceiro',
    'Carisma Natural',
    'Humor de Milhões',
    'Energia de Grupo',
    'Criatividade Caótica',
    'Modo Atleta',
    'Talento de Palco',
    'Drip Escolar',
    'Coração de Dorama',
    'Queridinho dos Professores',
    'Cérebro Turbo',
    'Caos Controlado',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: AppSpacing.screen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GradientHeroCard(
            leading: AppIconBox(
              icon: Icons.workspace_premium_rounded,
              color: Colors.white,
              backgroundColor: Color(0x24FFFFFF),
              size: 64,
              iconSize: 34,
            ),
            badgeIcon: Icons.local_fire_department_rounded,
            badgeText: 'Ranking de Popularidade',
            title: 'PiramidGame',
            description: 'IFPR – Campus Paranaguá',
            backgroundIcon: Icons.emoji_events_rounded,
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(child: AppMetricCard(icon: Icons.star_rounded, value: '15', label: 'Pontuação mínima')),
              SizedBox(width: 10),
              Expanded(child: AppMetricCard(icon: Icons.workspace_premium_rounded, value: '75', label: 'Pontuação máxima')),
              SizedBox(width: 10),
              Expanded(child: AppMetricCard(icon: Icons.category_rounded, value: '15', label: 'Critérios')),
            ],
          ),
          const SizedBox(height: 14),
          const AppSectionCard(
            icon: Icons.flag_rounded,
            title: 'Objetivo',
            children: [
              _BodyText(
                'O Ranking de Popularidade dos Alunos é um aplicativo desenvolvido em Flutter para fins didáticos. Ele permite cadastrar alunos do IFPR – Campus Paranaguá e avaliá-los em critérios descontraídos de convivência, destaque e participação na turma.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          const AppSectionCard(
            icon: Icons.auto_graph_rounded,
            title: 'Como funciona',
            children: [
              _BodyText(
                'Cada aluno recebe notas de 1 a 5 estrelas em 15 categorias. A soma dessas notas forma o Nível Lenda, usado para organizar o ranking geral.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppSectionCard(
            icon: Icons.checklist_rounded,
            title: 'Critérios avaliados',
            children: [
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: List.generate(
                  _criteria.length,
                  (index) => _CriteriaChip(number: index + 1, label: _criteria[index]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const AppSectionCard(
            icon: Icons.lock_rounded,
            title: 'Armazenamento',
            children: [
              _BodyText(
                'Todos os dados são armazenados localmente no dispositivo utilizando SharedPreferences. Nenhuma informação é enviada para servidores externos.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          const AppSectionCard(
            icon: Icons.palette_rounded,
            title: 'Tema',
            children: [
              _BodyText(
                'O aplicativo suporta tema claro e tema escuro. A alternância pode ser feita pelo botão no cabeçalho da aplicação.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          const AppSectionCard(
            icon: Icons.code_rounded,
            title: 'Tecnologias e recursos',
            children: [
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  AppPill(icon: Icons.flutter_dash_rounded, label: 'Flutter'),
                  AppPill(icon: Icons.storage_rounded, label: 'SharedPreferences'),
                  AppPill(icon: Icons.phone_android_rounded, label: 'Mobile'),
                  AppPill(icon: Icons.dark_mode_rounded, label: 'Tema escuro'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'Desenvolvido para a disciplina de Dispositivos Móveis',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(.8),
                fontSize: 12,
                height: 1.4,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 13,
        height: 1.48,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _CriteriaChip extends StatelessWidget {
  const _CriteriaChip({required this.number, required this.label});

  final int number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(7, 6, 10, 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: AppColors.primary,
            child: Text('$number', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
