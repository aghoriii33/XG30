import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String modelUsed;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.modelUsed = '',
  });

  // Model icon & color mapping
  Color _getModelColor(String model) {
    final m = model.toLowerCase();
    if (m.contains('claude')) return const Color(0xFFD97706);
    if (m.contains('gemini')) return const Color(0xFF4285F4);
    if (m.contains('grok')) return const Color(0xFFEC4899);
    if (m.contains('deepseek')) return const Color(0xFF06B6D4);
    return const Color(0xFF10A37F); // ChatGPT green
  }

  IconData _getModelIcon(String model) {
    final m = model.toLowerCase();
    if (m.contains('claude')) return Icons.psychology_rounded;
    if (m.contains('gemini')) return Icons.blur_on_rounded;
    if (m.contains('grok')) return Icons.all_inclusive_rounded;
    if (m.contains('deepseek')) return Icons.grain_rounded;
    return Icons.auto_awesome_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 6,
          bottom: 6,
          left: isUser ? 64 : 12,
          right: isUser ? 12 : 64,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Model label for AI messages
            if (!isUser && modelUsed.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getModelIcon(modelUsed),
                      size: 11,
                      color: _getModelColor(modelUsed),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      modelUsed.split('(').first.trim().toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 9,
                        color: _getModelColor(modelUsed),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),

            // Bubble
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    gradient: isUser
                        ? const LinearGradient(
                            colors: [
                              Color(0xFF6D28D9),
                              Color(0xFF4C1D95),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.07),
                              Colors.white.withOpacity(0.03),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    border: Border.all(
                      color: isUser
                          ? const Color(0xFF8B5CF6).withOpacity(0.4)
                          : Colors.white.withOpacity(0.07),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? const Color(0xFF8B5CF6).withOpacity(0.2)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildMessageContent(text),
                ),

                // Copy button for AI messages
                if (!isUser)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Copied!',
                                style: GoogleFonts.outfit(fontSize: 13)),
                            backgroundColor: const Color(0xFF8B5CF6),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.copy_rounded,
                            size: 11, color: Colors.white38),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(String text) {
    // Simple markdown-like rendering for code blocks and bold
    final lines = text.split('\n');
    final List<Widget> children = [];
    bool inCodeBlock = false;
    final List<String> codeLines = [];
    String codeLang = '';

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.startsWith('```')) {
        if (!inCodeBlock) {
          inCodeBlock = true;
          codeLang = line.replaceAll('`', '').trim();
        } else {
          // End of code block
          children.add(_buildCodeBlock(codeLines.join('\n'), codeLang));
          codeLines.clear();
          codeLang = '';
          inCodeBlock = false;
        }
        continue;
      }

      if (inCodeBlock) {
        codeLines.add(line);
        continue;
      }

      // Normal text line
      if (line.trim().isNotEmpty) {
        children.add(Padding(
          padding: EdgeInsets.only(bottom: i < lines.length - 1 ? 2 : 0),
          child: _buildRichText(line),
        ));
      } else if (children.isNotEmpty) {
        children.add(const SizedBox(height: 6));
      }
    }

    // Handle unclosed code block
    if (inCodeBlock && codeLines.isNotEmpty) {
      children.add(_buildCodeBlock(codeLines.join('\n'), codeLang));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildCodeBlock(String code, String lang) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lang.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    lang,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF8B5CF6),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Color(0xFF79C0FF),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRichText(String line) {
    // Handle markdown bold (**text**) and bullet points
    if (line.startsWith('* ') || line.startsWith('• ') || line.startsWith('- ')) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ',
              style: GoogleFonts.outfit(
                  color: const Color(0xFF8B5CF6),
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          Expanded(
            child: _buildBoldText(line.substring(2)),
          ),
        ],
      );
    }

    if (RegExp(r'^\d+\. ').hasMatch(line)) {
      return Padding(
        padding: const EdgeInsets.only(left: 4),
        child: _buildBoldText(line),
      );
    }

    if (line.startsWith('### ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 2),
        child: Text(
          line.substring(4),
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (line.startsWith('## ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 2),
        child: Text(
          line.substring(3),
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return _buildBoldText(line);
  }

  Widget _buildBoldText(String text) {
    // Split on **...**
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
            height: 1.5,
          ),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: GoogleFonts.outfit(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: GoogleFonts.outfit(
          fontSize: 14,
          color: Colors.white.withOpacity(0.9),
          height: 1.5,
        ),
      ));
    }

    if (spans.isEmpty) {
      return Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 14,
          color: Colors.white.withOpacity(0.9),
          height: 1.5,
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }
}
