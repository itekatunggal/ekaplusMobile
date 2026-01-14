import 'package:flutter/material.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/app_bar.dart';
import 'package:ekaplus_ekatunggal/constant.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // Helper method untuk mendapatkan responsive values
  double _getResponsiveValue(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return desktop;
    if (width >= 600) return tablet;
    return mobile;
  }

  @override
  Widget build(BuildContext context) {
    final _ = MediaQuery.of(context).size.width;

    // Responsive values
    final bannerHeight = _getResponsiveValue(
      context,
      mobile: 240.0,
      tablet: 300.0,
      desktop: 360.0,
    );

    final horizontalPadding = _getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 40.0,
      desktop: 60.0,
    );

    final verticalPadding = _getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
    );

    final titleSize = _getResponsiveValue(
      context,
      mobile: 20.0,
      tablet: 22.0,
      desktop: 26.0,
    );

    final bodyTextSize = _getResponsiveValue(
      context,
      mobile: 15.0,
      tablet: 16.0,
      desktop: 17.0,
    );

    final subheadingSize = _getResponsiveValue(
      context,
      mobile: 18.0,
      tablet: 20.0,
      desktop: 22.0,
    );

    final yellowBarWidth = _getResponsiveValue(
      context,
      mobile: 3.0,
      tablet: 4.0,
      desktop: 5.0,
    );

    final yellowBarHeight = _getResponsiveValue(
      context,
      mobile: 130.0,
      tablet: 140.0,
      desktop: 150.0,
    );

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: const CustomAppBar(title: 'Tentang Ekatunggal'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner / gambar besar
            SizedBox(
              width: double.infinity,
              height: bannerHeight,
              child: Builder(
                builder: (_) {
                  const asset = 'assets/images/account/about.png';
                  return Image.asset(
                    asset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.image,
                        size: _getResponsiveValue(
                          context,
                          mobile: 56.0,
                          tablet: 64.0,
                          desktop: 72.0,
                        ),
                        color: Colors.black26,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Konten
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title merah
                  Text(
                    'EKATUNGGAL',
                    style: TextStyle(
                      fontFamily: AppFonts.primaryFont,
                      color: AppColors.primaryColor,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(
                    height: _getResponsiveValue(
                      context,
                      mobile: 8.0,
                      tablet: 10.0,
                      desktop: 12.0,
                    ),
                  ),

                  // Paragraph ringkasan
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TEKS (rata kiri-kanan)
                      Expanded(
                        child: Text(
                          'Perusahaan distributor bahan baku material springbed dan sofa dan furniture. '
                          'Didirikan oleh Alm. Bapak Gapo Suseno pada tahun 1997. Ekatunggal berkomitmen untuk menghadirkan produk dan layanan berkualitas tinggi yang memenuhi kebutuhan masyarakat Indonesia.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontFamily: AppFonts.secondaryFont,
                            fontSize: bodyTextSize,
                            color: Color(0xFF667085),
                            height: 1.6,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: _getResponsiveValue(
                          context,
                          mobile: 6.0,
                          tablet: 8.0,
                          desktop: 10.0,
                        ),
                      ),

                      // GARIS KUNING
                      Container(
                        width: yellowBarWidth,
                        height: yellowBarHeight,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          borderRadius: BorderRadius.circular(
                            yellowBarWidth / 2,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: _getResponsiveValue(
                      context,
                      mobile: 16.0,
                      tablet: 18.0,
                      desktop: 20.0,
                    ),
                  ),

                  // Subheading center bold
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'LEBIH DARI 2 DEKADE BERDIRI',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: subheadingSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: _getResponsiveValue(
                      context,
                      mobile: 10.0,
                      tablet: 12.0,
                      desktop: 14.0,
                    ),
                  ),

                  // Paragraph panjang
                  Text(
                    'Ekatunggal terus berinovasi untuk memberikan solusi terbaik bagi pelanggan, sekaligus membangun hubungan jangka panjang berdasarkan kepercayaan, integritas, dan profesionalisme. Didukung oleh tim yang berpengalaman dan jaringan yang luas, Ekatunggal siap menjadi mitra terpercaya untuk masa depan yang lebih baik.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontFamily: AppFonts.secondaryFont,
                      fontSize: bodyTextSize,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),

                  SizedBox(
                    height: _getResponsiveValue(
                      context,
                      mobile: 24.0,
                      tablet: 28.0,
                      desktop: 32.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
