import 'dart:ui' show Size;

import 'package:flutter/foundation.dart';
import 'package:smap/features/scan/application/corner_geometry.dart';
import 'package:smap/features/scan/application/form_quad.dart';
import 'package:smap/features/scan/domain/optic_reading.dart';

/// A photo the shutter took, with what the detector found on it.
@immutable
class ScanPhoto {
  const ScanPhoto({required this.bytes, required this.size, this.form});

  /// The photo as the camera wrote it (JPEG with its EXIF orientation).
  final Uint8List bytes;

  /// The photo as it is shown (EXIF applied), in pixels.
  final Size size;

  /// The answer area the detector found, in the unit square of the photo;
  /// `null` when it found none (the corner screen then starts at the guide).
  final FormQuad? form;

  /// Where the corner screen's handles start.
  FormQuad get startQuad => form ?? CornerGeometry.guideQuad;
}

/// The stages of the scan, in order (spec §4.C "Durum makinesi": `capturing →
/// corners → preparing/uploading/reading → formCheck → … | examNotFound |
/// error`).
enum ScanStage {
  /// 4.3 Çekim: the camera.
  capture,

  /// 4.4 Köşe Düzenleme.
  corners,

  /// 4.5 Gönderim: prepare, send, read.
  upload,

  /// 4.7 Form Kontrol.
  review,

  /// 4.9 Deneme Bulunamadı: the exam request.
  request,

  /// 4.10: a full-screen error of the flow ([ScanErrorKind]).
  error,
}

/// The full-screen errors of the flow (pano 4.10).
enum ScanErrorKind {
  /// Kare 1 "Formu bulamadık": the reader found no answer area.
  formNotFound,

  /// Kare 3 "Bağlantı yok" (planned): the photo would be kept on the phone
  /// and sent when the connection returns. Shown only while
  /// `FeatureFlags.offlineQueueEnabled` is on; the queue does not exist yet.
  offline,
}

/// Where the scan is and what it carries from one stage to the next (the
/// photo is kept through every stage until the answers are taken: "Fotoğraf
/// yolu her durumda taşınır, başarıya kadar silinmez", spec 4.C).
///
/// Immutable; each step returns the next state, and a step that does not
/// apply in the current stage returns the state unchanged.
@immutable
class ScanFlowState {
  const ScanFlowState({
    this.stage = ScanStage.capture,
    this.photo,
    this.quad,
    this.flattened,
    this.reading,
    this.reply,
    this.errorKind,
  });

  final ScanStage stage;

  /// The photo, from the shutter on.
  final ScanPhoto? photo;

  /// The handles as the student left them, in the unit square of the photo.
  final FormQuad? quad;

  /// The straightened picture that is sent ("Devam").
  final Uint8List? flattened;

  /// What the reader found.
  final OpticReading? reading;

  /// The server's answer to the checked answers when the exam is unknown.
  final AnswerReply? reply;

  /// Which error the [ScanStage.error] stage shows.
  final ScanErrorKind? errorKind;

  /// The handles the corner screen shows: where the student left them, else
  /// where the detector (or the guide) put them.
  FormQuad? get cornersQuad => quad ?? photo?.startQuad;

  /// The shutter took [photo]: on to the corners.
  ScanFlowState captured(ScanPhoto photo) => stage == ScanStage.capture
      ? ScanFlowState(stage: ScanStage.corners, photo: photo)
      : this;

  /// "Tekrar Çek" and "Yeni Fotoğraf": back to a fresh camera.
  ScanFlowState retake() => const ScanFlowState();

  /// "Devam": the area at [quad] was straightened into [flattened]; the
  /// upload starts.
  ScanFlowState flattenedTo(Uint8List flattened, FormQuad quad) =>
      stage == ScanStage.corners
      ? ScanFlowState(
          stage: ScanStage.upload,
          photo: photo,
          quad: quad,
          flattened: flattened,
        )
      : this;

  /// "Vazgeç" on the upload screen: back to the corners, photo and handles
  /// kept.
  ScanFlowState backToCorners() => stage == ScanStage.upload
      ? ScanFlowState(stage: ScanStage.corners, photo: photo, quad: quad)
      : this;

  /// The reader answered: the check when it found an answer area, "Formu
  /// bulamadık" when it did not.
  ScanFlowState read(OpticReading reading) => stage == ScanStage.upload
      ? ScanFlowState(
          stage: reading.foundForm ? ScanStage.review : ScanStage.error,
          errorKind: reading.foundForm ? null : ScanErrorKind.formNotFound,
          photo: photo,
          quad: quad,
          flattened: flattened,
          reading: reading,
        )
      : this;

  /// The upload failed for want of a connection and the offline queue is on:
  /// the planned "Bağlantı yok" screen.
  ScanFlowState offline() => stage == ScanStage.upload
      ? ScanFlowState(
          stage: ScanStage.error,
          errorKind: ScanErrorKind.offline,
          photo: photo,
          quad: quad,
          flattened: flattened,
        )
      : this;

  /// "Şimdi Tekrar Dene" on the offline screen: the upload again, same photo.
  ScanFlowState retryUpload() =>
      stage == ScanStage.error && errorKind == ScanErrorKind.offline
      ? ScanFlowState(
          stage: ScanStage.upload,
          photo: photo,
          quad: quad,
          flattened: flattened,
        )
      : this;

  /// The checked answers went through but the exam is not in the system.
  ScanFlowState examNotFound(AnswerReply reply) => stage == ScanStage.review
      ? ScanFlowState(
          stage: ScanStage.request,
          photo: photo,
          quad: quad,
          flattened: flattened,
          reading: reading,
          reply: reply,
        )
      : this;

  @override
  bool operator ==(Object other) =>
      other is ScanFlowState &&
      other.stage == stage &&
      other.photo == photo &&
      other.quad == quad &&
      other.flattened == flattened &&
      other.reading == reading &&
      other.reply == reply &&
      other.errorKind == errorKind;

  @override
  int get hashCode =>
      Object.hash(stage, photo, quad, flattened, reading, reply, errorKind);
}
