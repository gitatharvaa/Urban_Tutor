import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:urban_tutor/models/tutor_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TeacherDetailPage — Premium Responsive Profile View
// ─────────────────────────────────────────────────────────────────────────────

class TeacherDetailPage extends StatelessWidget {
  final TutorModel tutor;

  const TeacherDetailPage({super.key, required this.tutor});

  // ── Helpers ────────────────────────────────────────────────────────────────
  String get _initials {
    final parts = tutor.personalInfo.fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1: return '${n}st';
      case 2: return '${n}nd';
      case 3: return '${n}rd';
      default: return '${n}th';
    }
  }

  bool get _hasSocial =>
      tutor.socialMedia.whatsapp.isNotEmpty ||
      tutor.socialMedia.facebook.isNotEmpty ||
      tutor.socialMedia.instagram.isNotEmpty ||
      tutor.socialMedia.twitter.isNotEmpty;

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final isTablet = w > 600;
    final hPad = isTablet ? w * 0.1 : 16.0;
    final sectionSpacing = isTablet ? 20.0 : 14.0;
    final cardPad = isTablet ? 24.0 : 18.0;
    final titleFs = isTablet ? 18.0 : 15.0;
    final bodyFs = isTablet ? 15.0 : 13.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, w, isTablet),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 20, hPad, mq.padding.bottom + 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Stats row ──
                _buildQuickStats(isTablet, bodyFs),
                SizedBox(height: sectionSpacing),

                // ── About / Bio ──
                if (tutor.bio.isNotEmpty) ...[
                  _buildSectionCard(
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    titleFs: titleFs,
                    cardPad: cardPad,
                    child: Text(
                      tutor.bio,
                      style: GoogleFonts.poppins(
                        fontSize: bodyFs + 1, height: 1.6,
                        color: const Color(0xFF444444),
                      ),
                    ),
                  ),
                  SizedBox(height: sectionSpacing),
                ],

                // ── Subjects ──
                if (tutor.professionalInfo.subjects.isNotEmpty) ...[
                  _buildSectionCard(
                    icon: Icons.menu_book_rounded,
                    title: 'Subjects',
                    titleFs: titleFs,
                    cardPad: cardPad,
                    child: Wrap(
                      spacing: 8, runSpacing: 8,
                      children: tutor.professionalInfo.subjects.map((s) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 16 : 12,
                            vertical: isTablet ? 8 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(s, style: GoogleFonts.poppins(fontSize: bodyFs, fontWeight: FontWeight.w600, color: AppColors.primaryBlue)),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: sectionSpacing),
                ],

                // ── Standards / Grades ──
                if (tutor.availability.standards.isNotEmpty) ...[
                  _buildSectionCard(
                    icon: Icons.school_rounded,
                    title: 'Grades Taught',
                    titleFs: titleFs,
                    cardPad: cardPad,
                    child: Wrap(
                      spacing: isTablet ? 10 : 8,
                      runSpacing: isTablet ? 10 : 8,
                      children: tutor.availability.standards.map((s) {
                        return Container(
                          width: isTablet ? 56 : 46,
                          height: isTablet ? 42 : 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _ordinal(s),
                            style: GoogleFonts.poppins(fontSize: bodyFs, fontWeight: FontWeight.w700, color: AppColors.primaryGreen),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: sectionSpacing),
                ],

                // ── Contact info ──
                _buildSectionCard(
                  icon: Icons.contact_mail_rounded,
                  title: 'Contact Information',
                  titleFs: titleFs,
                  cardPad: cardPad,
                  child: Column(
                    children: [
                      if (tutor.personalInfo.phone.isNotEmpty)
                        _buildContactRow(Icons.phone_rounded, 'Phone', tutor.personalInfo.phone, 'tel:${tutor.personalInfo.phone}', isTablet, bodyFs),
                      if (tutor.personalInfo.email.isNotEmpty)
                        _buildContactRow(Icons.email_rounded, 'Email', tutor.personalInfo.email, 'mailto:${tutor.personalInfo.email}', isTablet, bodyFs),
                      _buildContactRow(Icons.location_on_rounded, 'Location', '${tutor.location.area}, ${tutor.location.city}', null, isTablet, bodyFs),
                    ],
                  ),
                ),
                SizedBox(height: sectionSpacing),

                // ── Qualification document ──
                if (tutor.professionalInfo.qualificationImageUrl.isNotEmpty) ...[
                  _buildSectionCard(
                    icon: Icons.verified_rounded,
                    title: 'Qualification Document',
                    titleFs: titleFs,
                    cardPad: cardPad,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: tutor.professionalInfo.qualificationImageUrl,
                        width: double.infinity,
                        height: isTablet ? 260 : 200,
                        fit: BoxFit.contain,
                        placeholder: (ctx, url) => Container(
                          height: isTablet ? 260 : 200,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(color: AppColors.primaryBlue, strokeWidth: 2),
                        ),
                        errorWidget: (ctx, url, e) => Container(
                          height: isTablet ? 260 : 200,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image_rounded, size: 40, color: AppColors.textLight),
                              const SizedBox(height: 8),
                              Text('Could not load image', style: GoogleFonts.poppins(fontSize: bodyFs, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: sectionSpacing),
                ],

                // ── Social media ──
                if (_hasSocial) ...[
                  _buildSectionCard(
                    icon: Icons.share_rounded,
                    title: 'Social Media',
                    titleFs: titleFs,
                    cardPad: cardPad,
                    child: Wrap(
                      spacing: 10, runSpacing: 10,
                      children: [
                        if (tutor.socialMedia.whatsapp.isNotEmpty)
                          _buildSocialChip(Icons.phone_rounded, 'WhatsApp', const Color(0xFF25D366), 'https://wa.me/${tutor.socialMedia.whatsapp}', bodyFs),
                        if (tutor.socialMedia.facebook.isNotEmpty)
                          _buildSocialChip(Icons.facebook_rounded, 'Facebook', const Color(0xFF1877F2), tutor.socialMedia.facebook, bodyFs),
                        if (tutor.socialMedia.instagram.isNotEmpty)
                          _buildSocialChip(Icons.camera_alt_rounded, 'Instagram', const Color(0xFFE4405F), 'https://instagram.com/${tutor.socialMedia.instagram}', bodyFs),
                        if (tutor.socialMedia.twitter.isNotEmpty)
                          _buildSocialChip(Icons.alternate_email_rounded, 'Twitter', const Color(0xFF1DA1F2), 'https://twitter.com/${tutor.socialMedia.twitter}', bodyFs),
                      ],
                    ),
                  ),
                  SizedBox(height: sectionSpacing),
                ],

                const SizedBox(height: 8),

                // ── CTA button ──
                if (tutor.personalInfo.phone.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    height: isTablet ? 58 : 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl('tel:${tutor.personalInfo.phone}'),
                      icon: const Icon(Icons.call_rounded, size: 20),
                      label: Text(
                        'Contact ${tutor.personalInfo.fullName.split(' ').first}',
                        style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  SLIVER APP BAR — Hero header with large profile picture
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildSliverAppBar(BuildContext context, double screenWidth, bool isTablet) {
    // Responsive avatar: much bigger now
    final avatarR = isTablet ? 72.0 : 60.0;
    // Enough height for: status bar + avatar + spacing + name + badge + bottom padding
    final expandedH = isTablet ? 380.0 : 340.0;
    final nameFs = isTablet ? 26.0 : 22.0;
    final qualFs = isTablet ? 14.0 : 13.0;

    return SliverAppBar(
      expandedHeight: expandedH,
      pinned: true,
      backgroundColor: AppColors.primaryBlue,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBlue,
                AppColors.primaryBlue.withValues(alpha: 0.85),
                AppColors.primaryGreen.withValues(alpha: 0.5),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                // Decorative circles — responsive positions
                Positioned(
                  top: isTablet ? 0 : -10,
                  right: screenWidth * 0.06,
                  child: _decorCircle(isTablet ? 110 : 80, 0.07),
                ),
                Positioned(
                  top: isTablet ? 30 : 15,
                  right: screenWidth * 0.02,
                  child: _decorCircle(isTablet ? 55 : 40, 0.05),
                ),
                Positioned(
                  bottom: isTablet ? 60 : 50,
                  left: screenWidth * 0.04,
                  child: _decorCircle(isTablet ? 70 : 50, 0.05),
                ),

                // Profile content — centered
                Positioned(
                  left: 0, right: 0,
                  bottom: 24,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Avatar ──
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: avatarR,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: tutor.personalInfo.profileImageUrl.isNotEmpty
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: tutor.personalInfo.profileImageUrl,
                                    width: avatarR * 2, height: avatarR * 2,
                                    fit: BoxFit.cover,
                                    placeholder: (c, u) => _avatarPlaceholder(avatarR),
                                    errorWidget: (c, u, e) => _avatarPlaceholder(avatarR),
                                  ),
                                )
                              : _avatarPlaceholder(avatarR),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Name ──
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                        child: Text(
                          tutor.personalInfo.fullName,
                          style: GoogleFonts.poppins(
                            fontSize: nameFs,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // ── Qualification badge ──
                      if (tutor.professionalInfo.qualification.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.school_rounded, size: 14, color: Colors.white.withValues(alpha: 0.9)),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  tutor.professionalInfo.qualification,
                                  style: GoogleFonts.poppins(fontSize: qualFs, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.95)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatarPlaceholder(double r) {
    return Container(
      width: r * 2, height: r * 2,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _initials,
          style: GoogleFonts.poppins(
            fontSize: r * 0.6,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _decorCircle(double size, double opacity) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  QUICK STATS ROW
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildQuickStats(bool isTablet, double baseFs) {
    final iconSize = isTablet ? 20.0 : 16.0;
    final iconPad = isTablet ? 10.0 : 7.0;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 18 : 14,
        horizontal: isTablet ? 12 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(Icons.work_history_rounded, '${tutor.professionalInfo.experience}', 'Years Exp.', AppColors.primaryBlue, isTablet, baseFs, iconSize, iconPad),
          _statDivider(isTablet),
          _buildStatItem(Icons.currency_rupee_rounded, '₹${tutor.professionalInfo.monthlyRate.toInt()}', '/month', AppColors.primaryGreen, isTablet, baseFs, iconSize, iconPad),
          _statDivider(isTablet),
          _buildStatItem(
            Icons.star_rounded,
            tutor.ratings.averageRating > 0 ? tutor.ratings.averageRating.toStringAsFixed(1) : '—',
            tutor.ratings.totalReviews > 0 ? '${tutor.ratings.totalReviews} reviews' : 'No reviews',
            const Color(0xFFF4A921),
            isTablet, baseFs, iconSize, iconPad,
          ),
          _statDivider(isTablet),
          _buildStatItem(Icons.location_on_rounded, tutor.location.city, tutor.location.area, const Color(0xFFE57373), isTablet, baseFs, iconSize, iconPad),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color, bool isTablet, double baseFs, double iconSize, double iconPad) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(iconPad),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: iconSize, color: color),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: baseFs + 1, fontWeight: FontWeight.w700, color: const Color(0xFF2D2D2D)),
            maxLines: 1, overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: baseFs - 3, color: const Color(0xFF757575)),
            maxLines: 1, overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _statDivider(bool isTablet) {
    return Container(
      width: 1,
      height: isTablet ? 48 : 38,
      color: const Color(0xFFEEEEEE),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  SECTION CARD
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
    required double titleFs,
    required double cardPad,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: titleFs, fontWeight: FontWeight.w700, color: const Color(0xFF2D2D2D)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  CONTACT ROW
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildContactRow(IconData icon, String label, String value, String? launchUri, bool isTablet, double baseFs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: launchUri != null ? () => _launchUrl(launchUri) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 12,
            vertical: isTablet ? 14 : 10,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 10 : 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: isTablet ? 18 : 16, color: AppColors.primaryBlue),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: GoogleFonts.poppins(fontSize: baseFs - 2, fontWeight: FontWeight.w500, color: const Color(0xFF757575))),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: GoogleFonts.poppins(
                        fontSize: baseFs + 1, fontWeight: FontWeight.w600,
                        color: launchUri != null ? AppColors.primaryBlue : const Color(0xFF2D2D2D),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (launchUri != null)
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primaryBlue.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  SOCIAL CHIP
  // ═════════════════════════════════════════════════════════════════════════════

  Widget _buildSocialChip(IconData icon, String label, Color color, String url, double baseFs) {
    return InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.poppins(fontSize: baseFs, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  //  URL LAUNCHER
  // ═════════════════════════════════════════════════════════════════════════════

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
