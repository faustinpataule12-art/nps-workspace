[Contenu du fichier "editor_screen.dart" (Format inconnu traité en texte brut)] :

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../services/apk_service.dart';
import 'result_screen.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  String? _apkPath;
  String? _apkName;
  File? _newIcon;
  File? _splashImage;
  File? _splashLogo;
  Color _splashBgColor = const Color(0xFF0D0F14);
  bool _isProcessing = false;
  int _currentStep = 0;
  String _statusMsg = '';

  Map<String, dynamic>? _apkInfo;
  bool _isLoadingInfo = false;
  bool _isExportingInfo = false;
  bool _isExportingDiagnostic = false;
  bool _isExportingIconDiagnostic = false;
  bool _isExportingArscDiagnostic = false;
  bool _isExportingSelectionDiagnostic = false;

  Future<void> _pickApk() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['apk'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _apkPath = result.files.single.path;
        _apkName = result.files.single.name;
        _apkInfo = null;
      });
    }
  }

  Future<void> _loadApkInfo() async {
    if (_apkPath == null) return;
    setState(() => _isLoadingInfo = true);
    try {
      final service = ApkService();
      final info = await service.readApkInfo(_apkPath!);
      setState(() {
        _apkInfo = info;
        _isLoadingInfo = false;
      });
    } catch (e) {
      setState(() => _isLoadingInfo = false);
      _showSnack('Impossible de lire les infos : $e');
    }
  }

  String _buildInfoReport() {
    if (_apkInfo == null) return '';
    final info = _apkInfo!;
    final permissions = (info['permissions'] as List).cast<String>();

    final buffer = StringBuffer();
    buffer.writeln('INFOS DE PUBLICATION — ${_apkName ?? "APK"}');
    buffer.writeln('Généré par ICÔNE-APP (NPS.NELSON)');
    buffer.writeln('');
    buffer.writeln('Package ID       : ${info['packageId']}');
    buffer.writeln('Nom affiché      : ${info['appLabel']}');
    buffer.writeln('Version          : ${info['versionName']} (code ${info['versionCode']})');
    buffer.writeln('SDK minimum      : ${info['minSdkVersion']}');
    buffer.writeln('SDK cible        : ${info['targetSdkVersion']}');
    buffer.writeln('Taille APK       : ${info['apkSizeMb']} Mo');
    buffer.writeln('');
    buffer.writeln('PERMISSIONS (${permissions.length}) :');
    if (permissions.isEmpty) {
      buffer.writeln('  Aucune détectée');
    } else {
      for (final p in permissions) {
        buffer.writeln('  - $p');
      }
    }
    return buffer.toString();
  }

  Future<void> _exportInfoAsFile() async {
    if (_apkInfo == null) return;
    setState(() => _isExportingInfo = true);
    try {
      final report = _buildInfoReport();
      final externalDir = await getExternalStorageDirectory();
      final baseName = (_apkName ?? 'apk').replaceAll('.apk', '');
      final filePath = '${externalDir!.path}/${baseName}_infos.txt';
      final file = File(filePath);
      await file.writeAsString(report);

      setState(() => _isExportingInfo = false);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Infos de publication — ${_apkName ?? "APK"}',
      );
    } catch (e) {
      setState(() => _isExportingInfo = false);
      _showSnack('Erreur export : $e');
    }
  }

  Future<void> _exportManifestDiagnostic() async {
    if (_apkPath == null) return;
    setState(() => _isExportingDiagnostic = true);
    try {
      final service = ApkService();
      final filePath = await service.exportManifestDiagnostic(_apkPath!);

      setState(() => _isExportingDiagnostic = false);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Diagnostic manifeste — ${_apkName ?? "APK"}',
      );
    } catch (e) {
      setState(() => _isExportingDiagnostic = false);
      _showSnack('Erreur diagnostic : $e');
    }
  }

  Future<void> _exportIconDiagnostic() async {
    if (_apkPath == null) return;
    setState(() => _isExportingIconDiagnostic = true);
    try {
      final service = ApkService();
      final filePath = await service.exportIconDiagnostic(_apkPath!);

      setState(() => _isExportingIconDiagnostic = false);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Diagnostic icônes — ${_apkName ?? "APK"}',
      );
    } catch (e) {
      setState(() => _isExportingIconDiagnostic = false);
      _showSnack('Erreur diagnostic : $e');
    }
  }

  Future<void> _exportArscDiagnostic() async {
    if (_apkPath == null) return;
    setState(() => _isExportingArscDiagnostic = true);
    try {
      final service = ApkService();
      final filePath = await service.exportArscDiagnostic(_apkPath!);

      setState(() => _isExportingArscDiagnostic = false);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Diagnostic resources.arsc — ${_apkName ?? "APK"}',
      );
    } catch (e) {
      setState(() => _isExportingArscDiagnostic = false);
      _showSnack('Erreur diagnostic : $e');
    }
  }

  Future<void> _exportSelectionDiagnostic() async {
    if (_apkPath == null) return;
    setState(() => _isExportingSelectionDiagnostic = true);
    try {
      final service = ApkService();
      final filePath = await service.exportIconSelectionDiagnostic(_apkPath!);

      setState(() => _isExportingSelectionDiagnostic = false);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Diagnostic sélection — ${_apkName ?? "APK"}',
      );
    } catch (e) {
      setState(() => _isExportingSelectionDiagnostic = false);
      _showSnack('Erreur diagnostic : $e');
    }
  }

  Future<void> _pickIcon() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _newIcon = File(img.path));
  }

  Future<void> _pickSplashImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _splashImage = File(img.path));
  }

  Future<void> _pickSplashLogo() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _splashLogo = File(img.path));
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Couleur du splash', style: GoogleFonts.jetBrainsMono(color: AppTheme.accent)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _splashBgColor,
            onColorChanged: (c) => setState(() => _splashBgColor = c),
            enableAlpha: false,
            hexInputBar: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }

  Future<void> _process() async {
    if (_apkPath == null) {
      _showSnack('Sélectionne d\'abord un APK !');
      return;
    }
    if (_newIcon == null && _splashImage == null && _splashLogo == null) {
      _showSnack('Sélectionne au moins une icône ou un splash !');
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMsg = 'Décompilation de l\'APK...';
      _currentStep = 0;
    });

    try {
      final service = ApkService();

      final outputPath = await service.processApk(
        apkPath: _apkPath!,
        newIcon: _newIcon,
        splashImage: _splashImage,
        splashLogo: _splashLogo,
        splashBgColor: _splashBgColor,
        onProgress: (step, msg) {
          setState(() {
            _currentStep = step;
            _statusMsg = msg;
          });
        },
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(outputPath: outputPath)),
      );
    } catch (e) {
      setState(() => _isProcessing = false);
      _showSnack('Erreur : $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter()),
        backgroundColor: AppTheme.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ÉDITEUR APK'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isProcessing ? _buildProcessing() : _buildEditor(),
    );
  }

  Widget _buildProcessing() {
    final steps = [
      'Décompilation de l\'APK...',
      'Remplacement des icônes...',
      'Modification du splash screen...',
      'Recompilation...',
      'Signature de l\'APK...',
      'Finalisation...',
    ];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: AppTheme.accent,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _statusMsg,
              style: GoogleFonts.jetBrainsMono(color: AppTheme.accent, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ...List.generate(steps.length, (i) => _StepRow(
              label: steps[i],
              state: i < _currentStep
                  ? _StepState.done
                  : i == _currentStep
                      ? _StepState.active
                      : _StepState.pending,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step 1: APK
          _SectionTitle(number: '01', title: 'SÉLECTIONNER L\'APK'),
          const SizedBox(height: 12),
          _PickerCard(
            emoji: '📦',
            label: _apkName ?? 'Aucun APK sélectionné',
            subtitle: _apkPath != null ? 'APK chargé avec succès' : 'Appuie pour choisir un fichier .apk',
            isSelected: _apkPath != null,
            onTap: _pickApk,
          ),

          if (_apkPath != null) ...[
            const SizedBox(height: 12),
            _InfoButton(
              isLoading: _isLoadingInfo,
              hasInfo: _apkInfo != null,
              onTap: _loadApkInfo,
            ),
            if (_apkInfo != null) ...[
              const SizedBox(height: 12),
              _ApkInfoCard(info: _apkInfo!),
              const SizedBox(height: 10),
              _ExportButton(
                isLoading: _isExportingInfo,
                icon: Icons.download,
                label: 'Télécharger en fichier .txt',
                onTap: _exportInfoAsFile,
              ),
            ],
            const SizedBox(height: 10),
            _ExportButton(
              isLoading: _isExportingDiagnostic,
              icon: Icons.bug_report_outlined,
              label: 'Diagnostic manifeste (.txt)',
              onTap: _exportManifestDiagnostic,
            ),
            const SizedBox(height: 10),
            _ExportButton(
              isLoading: _isExportingIconDiagnostic,
              icon: Icons.image_search,
              label: 'Diagnostic icônes (.txt)',
              onTap: _exportIconDiagnostic,
            ),
            const SizedBox(height: 10),
            _ExportButton(
              isLoading: _isExportingArscDiagnostic,
              icon: Icons.storage,
              label: 'Diagnostic resources.arsc (.txt)',
              onTap: _exportArscDiagnostic,
            ),
            const SizedBox(height: 10),
            _ExportButton(
              isLoading: _isExportingSelectionDiagnostic,
              icon: Icons.rule,
              label: 'Diagnostic sélection icône (.txt)',
              onTap: _exportSelectionDiagnostic,
            ),
          ],
          const SizedBox(height: 28),

          // Step 2: Icon
          _SectionTitle(number: '02', title: 'NOUVELLE ICÔNE'),
          const SizedBox(height: 12),
          _ImagePickerCard(
            emoji: '🖼️',
            label: 'Icône de l\'application',
            subtitle: 'Remplace dans toutes les tailles (48→192px)',
            image: _newIcon,
            onTap: _pickIcon,
          ),
          const SizedBox(height: 28),

          // Step 3: Splash
          _SectionTitle(number: '03', title: 'SPLASH SCREEN'),
          const SizedBox(height: 12),
          _ImagePickerCard(
            emoji: '🌅',
            label: 'Image de fond',
            subtitle: 'Image plein écran au démarrage',
            image: _splashImage,
            onTap: _pickSplashImage,
          ),
          const SizedBox(height: 12),
          _ImagePickerCard(
            emoji: '✨',
            label: 'Logo centré',
            subtitle: 'Logo affiché au centre du splash',
            image: _splashLogo,
            onTap: _pickSplashLogo,
          ),
          const SizedBox(height: 12),
          _ColorPickerCard(
            color: _splashBgColor,
            onTap: _pickColor,
          ),
          const SizedBox(height: 36),

          // Process button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _process,
              child: const Text('⚙️  MODIFIER L\'APK'),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '* L\'APK sera décompilé, modifié, recompilé et signé automatiquement.',
            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Widgets ───────────────────────────────────────────────

class _InfoButton extends StatelessWidget {
  final bool isLoading;
  final bool hasInfo;
  final VoidCallback onTap;

  const _InfoButton({required this.isLoading, required this.hasInfo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent),
              )
            else
              const Icon(Icons.info_outline, size: 18, color: AppTheme.accent),
            const SizedBox(width: 10),
            Text(
              hasInfo ? 'Actualiser les infos de publication' : 'Voir les infos de publication (ID, version...)',
              style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final bool isLoading;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ExportButton({
    required this.isLoading,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.accentDim,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent),
              )
            else
              Icon(icon, size: 18, color: AppTheme.accent),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApkInfoCard extends StatelessWidget {
  final Map<String, dynamic> info;

  const _ApkInfoCard({required this.info});

  @override
  Widget build(BuildContext context) {
    final permissions = (info['permissions'] as List).cast<String>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'Package ID', value: '${info['packageId']}'),
          _InfoRow(label: 'Nom affiché', value: '${info['appLabel']}'),
          _InfoRow(label: 'Version', value: '${info['versionName']} (code ${info['versionCode']})'),
          _InfoRow(label: 'SDK min / cible', value: '${info['minSdkVersion']} / ${info['targetSdkVersion']}'),
          _InfoRow(label: 'Taille APK', value: '${info['apkSizeMb']} Mo'),
          const SizedBox(height: 8),
          Text(
            'PERMISSIONS (${permissions.length})',
            style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          if (permissions.isEmpty)
            Text('Aucune détectée', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted))
          else
            ...permissions.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '• $p',
                    style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppTheme.textPrimary),
                  ),
                )),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(fontSize: 13, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String number;
  final String title;
  const _SectionTitle({required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          number,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            color: AppTheme.accent,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _PickerCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PickerCard({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.accent.withOpacity(0.4) : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      color: isSelected ? AppTheme.accent : AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.add_circle_outline,
              color: isSelected ? AppTheme.accent : AppTheme.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String subtitle;
  final File? image;
  final VoidCallback onTap;

  const _ImagePickerCard({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: image != null ? AppTheme.accent.withOpacity(0.4) : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(image!, width: 44, height: 44, fit: BoxFit.cover),
              )
            else
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.accentDim,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      color: image != null ? AppTheme.accent : AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            Icon(
              image != null ? Icons.check_circle : Icons.add_circle_outline,
              color: image != null ? AppTheme.accent : AppTheme.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorPickerCard extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _ColorPickerCard({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Couleur de fond',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                    style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.color_lens_outlined, color: AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

enum _StepState { pending, active, done }

class _StepRow extends StatelessWidget {
  final String label;
  final _StepState state;

  const _StepRow({required this.label, required this.state});

  @override
  Widget build(BuildContext context) {
    final color = state == _StepState.done
        ? AppTheme.accent
        : state == _StepState.active
            ? AppTheme.textPrimary
            : AppTheme.textMuted;
    final icon = state == _StepState.done
        ? '✅'
        : state == _StepState.active
            ? '⏳'
            : '○';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}
