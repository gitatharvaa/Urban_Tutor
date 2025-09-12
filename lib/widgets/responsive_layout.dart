import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool enableMaxWidth;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.padding,
    this.enableMaxWidth = false, // Changed default to false for full screen
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen dimensions
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        
        // Define breakpoints
        final isMobile = screenWidth < 768;
        final isTablet = screenWidth >= 768 && screenWidth < 1024;
        final isDesktop = screenWidth >= 1024;
        
        // Calculate responsive padding - minimal for full screen usage
        EdgeInsetsGeometry responsivePadding = padding ??
            EdgeInsets.symmetric(
              horizontal: _getHorizontalPadding(screenWidth),
              vertical: _getVerticalPadding(screenHeight),
            );

        return Container(
          width: double.infinity, // Use full width
          height: double.infinity, // Use full height
          padding: responsivePadding,
          child: child,
        );
      },
    );
  }

  double _getHorizontalPadding(double screenWidth) {
    // Minimal horizontal padding for better screen utilization
    if (screenWidth < 768) {
      return 0; // Mobile - no padding for full width
    } else if (screenWidth < 1024) {
      return 0; // Tablet - no padding for full width
    } else {
      return 0; // Desktop - no padding for full width
    }
  }

  double _getVerticalPadding(double screenHeight) {
    // Minimal vertical padding
    return 0; // No vertical padding for full screen usage
  }
}

class ResponsiveBreakpoints {
  static const double mobile = 768;
  static const double tablet = 1024;
  static const double desktop = 1200;
  static const double largeDesktop = 1440;
  
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tablet;
  }
  
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  static bool isExtraLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktop;
  }
}

class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;
  final T? largeDesktop;
  
  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });
  
  T getValue(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= ResponsiveBreakpoints.largeDesktop) {
      return largeDesktop ?? desktop ?? tablet ?? mobile;
    } else if (width >= ResponsiveBreakpoints.desktop) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= ResponsiveBreakpoints.tablet) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;
  
  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });
  
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= ResponsiveBreakpoints.largeDesktop) {
      return largeDesktop ?? desktop ?? tablet ?? mobile;
    } else if (width >= ResponsiveBreakpoints.desktop) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= ResponsiveBreakpoints.tablet) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

// Extension for easy responsive values
extension ResponsiveExtensions on BuildContext {
  bool get isMobile => ResponsiveBreakpoints.isMobile(this);
  bool get isTablet => ResponsiveBreakpoints.isTablet(this);
  bool get isDesktop => ResponsiveBreakpoints.isDesktop(this);
  bool get isLargeScreen => ResponsiveBreakpoints.isLargeScreen(this);
  bool get isExtraLargeScreen => ResponsiveBreakpoints.isExtraLargeScreen(this);
  
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    final width = screenWidth;
    
    if (width >= ResponsiveBreakpoints.largeDesktop) {
      return largeDesktop ?? desktop ?? tablet ?? mobile;
    } else if (width >= ResponsiveBreakpoints.desktop) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= ResponsiveBreakpoints.tablet) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
}

// Responsive spacing helper with better screen utilization
class ResponsiveSpacing {
  static double getSpacing(BuildContext context, {
    double mobile = 16.0,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return context.responsive<double>(
      mobile: mobile,
      tablet: tablet ?? mobile * 1.2,
      desktop: desktop ?? mobile * 1.4,
      largeDesktop: largeDesktop ?? mobile * 1.6,
    );
  }
  
  static EdgeInsets getPadding(BuildContext context, {
    EdgeInsets mobile = const EdgeInsets.all(16.0),
    EdgeInsets? tablet,
    EdgeInsets? desktop,
    EdgeInsets? largeDesktop,
  }) {
    return context.responsive<EdgeInsets>(
      mobile: mobile,
      tablet: tablet ?? EdgeInsets.all(mobile.left * 1.2),
      desktop: desktop ?? EdgeInsets.all(mobile.left * 1.4),
      largeDesktop: largeDesktop ?? EdgeInsets.all(mobile.left * 1.6),
    );
  }

  // New method for content padding that respects full screen usage
  static EdgeInsets getContentPadding(BuildContext context) {
    return context.responsive<EdgeInsets>(
      mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tablet: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      desktop: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      largeDesktop: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
    );
  }

  // Method for form spacing
  static double getFormSpacing(BuildContext context) {
    return context.responsive<double>(
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
      largeDesktop: 28.0,
    );
  }

  // Method for section spacing
  static double getSectionSpacing(BuildContext context) {
    return context.responsive<double>(
      mobile: 24.0,
      tablet: 28.0,
      desktop: 32.0,
      largeDesktop: 36.0,
    );
  }
}

// Responsive text scaling
class ResponsiveText {
  static TextStyle getHeadlineStyle(BuildContext context, {
    double baseFontSize = 24.0,
    FontWeight fontWeight = FontWeight.bold,
    Color? color,
  }) {
    final scaledSize = context.responsive<double>(
      mobile: baseFontSize,
      tablet: baseFontSize * 1.1,
      desktop: baseFontSize * 1.2,
      largeDesktop: baseFontSize * 1.3,
    );

    return TextStyle(
      fontSize: scaledSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle getBodyStyle(BuildContext context, {
    double baseFontSize = 16.0,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    final scaledSize = context.responsive<double>(
      mobile: baseFontSize,
      tablet: baseFontSize * 1.05,
      desktop: baseFontSize * 1.1,
      largeDesktop: baseFontSize * 1.15,
    );

    return TextStyle(
      fontSize: scaledSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}

// Container for constrained content when needed
class ConstrainedResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ConstrainedResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: padding,
        child: child,
      ),
    );
  }
}

// Full screen container (default behavior)
class FullScreenContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const FullScreenContainer({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: padding,
      color: backgroundColor,
      child: child,
    );
  }
}

// Adaptive grid for responsive layouts
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
  });

  @override
  Widget build(BuildContext context) {
    final columns = context.responsive<int>(
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}
