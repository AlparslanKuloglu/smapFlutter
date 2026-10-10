part of '../optic_mark_detection_view.dart';

@immutable
final class _PreviewTopInfoWidget extends StatelessWidget {
  final Stream<AppStatus>? statusTakePhotoPage;
  const _PreviewTopInfoWidget({this.statusTakePhotoPage});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: statusTakePhotoPage,
      builder: (BuildContext context, AsyncSnapshot<AppStatus> snapshot) {
        if (snapshot.data != AppStatus.success) {
          return ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5, tileMode: TileMode.decal),
              child: ColoredBox(
                color: Colors.grey.shade100.withOpacity(.5),
                child: const SafeArea(
                  minimum: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Optik Form Okuma',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Görüntüyü cevapları kodladığınız alanın tamamını görecek şekilde üzerine getiriniz',
                        style: TextStyle(fontSize: 16, height: 1.1),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
