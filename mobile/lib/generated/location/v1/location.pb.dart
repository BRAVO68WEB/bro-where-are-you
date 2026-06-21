// This is a generated file - do not edit.
//
// Generated from location/v1/location.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class LocationUpdate extends $pb.GeneratedMessage {
  factory LocationUpdate({
    $core.String? deviceId,
    $core.String? journeyId,
    $core.double? latitude,
    $core.double? longitude,
    $core.double? accuracy,
    $core.double? speed,
    $core.double? altitude,
    $core.double? heading,
    $fixnum.Int64? timestampMs,
    $core.String? source,
    $core.double? heartRate,
    $core.String? transportMode,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    if (journeyId != null) result.journeyId = journeyId;
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (accuracy != null) result.accuracy = accuracy;
    if (speed != null) result.speed = speed;
    if (altitude != null) result.altitude = altitude;
    if (heading != null) result.heading = heading;
    if (timestampMs != null) result.timestampMs = timestampMs;
    if (source != null) result.source = source;
    if (heartRate != null) result.heartRate = heartRate;
    if (transportMode != null) result.transportMode = transportMode;
    return result;
  }

  LocationUpdate._();

  factory LocationUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LocationUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LocationUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..aOS(2, _omitFieldNames ? '' : 'journeyId')
    ..aD(3, _omitFieldNames ? '' : 'latitude')
    ..aD(4, _omitFieldNames ? '' : 'longitude')
    ..aD(5, _omitFieldNames ? '' : 'accuracy', fieldType: $pb.PbFieldType.OF)
    ..aD(6, _omitFieldNames ? '' : 'speed', fieldType: $pb.PbFieldType.OF)
    ..aD(7, _omitFieldNames ? '' : 'altitude', fieldType: $pb.PbFieldType.OF)
    ..aD(8, _omitFieldNames ? '' : 'heading', fieldType: $pb.PbFieldType.OF)
    ..aInt64(9, _omitFieldNames ? '' : 'timestampMs')
    ..aOS(10, _omitFieldNames ? '' : 'source')
    ..aD(11, _omitFieldNames ? '' : 'heartRate', fieldType: $pb.PbFieldType.OF)
    ..aOS(12, _omitFieldNames ? '' : 'transportMode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LocationUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LocationUpdate copyWith(void Function(LocationUpdate) updates) =>
      super.copyWith((message) => updates(message as LocationUpdate))
          as LocationUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LocationUpdate create() => LocationUpdate._();
  @$core.override
  LocationUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LocationUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LocationUpdate>(create);
  static LocationUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get journeyId => $_getSZ(1);
  @$pb.TagNumber(2)
  set journeyId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasJourneyId() => $_has(1);
  @$pb.TagNumber(2)
  void clearJourneyId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get latitude => $_getN(2);
  @$pb.TagNumber(3)
  set latitude($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLatitude() => $_has(2);
  @$pb.TagNumber(3)
  void clearLatitude() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get longitude => $_getN(3);
  @$pb.TagNumber(4)
  set longitude($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLongitude() => $_has(3);
  @$pb.TagNumber(4)
  void clearLongitude() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get accuracy => $_getN(4);
  @$pb.TagNumber(5)
  set accuracy($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAccuracy() => $_has(4);
  @$pb.TagNumber(5)
  void clearAccuracy() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get speed => $_getN(5);
  @$pb.TagNumber(6)
  set speed($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSpeed() => $_has(5);
  @$pb.TagNumber(6)
  void clearSpeed() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get altitude => $_getN(6);
  @$pb.TagNumber(7)
  set altitude($core.double value) => $_setFloat(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAltitude() => $_has(6);
  @$pb.TagNumber(7)
  void clearAltitude() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get heading => $_getN(7);
  @$pb.TagNumber(8)
  set heading($core.double value) => $_setFloat(7, value);
  @$pb.TagNumber(8)
  $core.bool hasHeading() => $_has(7);
  @$pb.TagNumber(8)
  void clearHeading() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get timestampMs => $_getI64(8);
  @$pb.TagNumber(9)
  set timestampMs($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTimestampMs() => $_has(8);
  @$pb.TagNumber(9)
  void clearTimestampMs() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get source => $_getSZ(9);
  @$pb.TagNumber(10)
  set source($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasSource() => $_has(9);
  @$pb.TagNumber(10)
  void clearSource() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get heartRate => $_getN(10);
  @$pb.TagNumber(11)
  set heartRate($core.double value) => $_setFloat(10, value);
  @$pb.TagNumber(11)
  $core.bool hasHeartRate() => $_has(10);
  @$pb.TagNumber(11)
  void clearHeartRate() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get transportMode => $_getSZ(11);
  @$pb.TagNumber(12)
  set transportMode($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasTransportMode() => $_has(11);
  @$pb.TagNumber(12)
  void clearTransportMode() => $_clearField(12);
}

class LocationAck extends $pb.GeneratedMessage {
  factory LocationAck({
    $core.int? pointsReceived,
    $core.String? journeyId,
  }) {
    final result = create();
    if (pointsReceived != null) result.pointsReceived = pointsReceived;
    if (journeyId != null) result.journeyId = journeyId;
    return result;
  }

  LocationAck._();

  factory LocationAck.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LocationAck.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LocationAck',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pointsReceived')
    ..aOS(2, _omitFieldNames ? '' : 'journeyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LocationAck clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LocationAck copyWith(void Function(LocationAck) updates) =>
      super.copyWith((message) => updates(message as LocationAck))
          as LocationAck;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LocationAck create() => LocationAck._();
  @$core.override
  LocationAck createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LocationAck getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LocationAck>(create);
  static LocationAck? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pointsReceived => $_getIZ(0);
  @$pb.TagNumber(1)
  set pointsReceived($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPointsReceived() => $_has(0);
  @$pb.TagNumber(1)
  void clearPointsReceived() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get journeyId => $_getSZ(1);
  @$pb.TagNumber(2)
  set journeyId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasJourneyId() => $_has(1);
  @$pb.TagNumber(2)
  void clearJourneyId() => $_clearField(2);
}

class LocationPoint extends $pb.GeneratedMessage {
  factory LocationPoint({
    $core.double? latitude,
    $core.double? longitude,
    $core.double? accuracy,
    $core.double? speed,
    $core.double? altitude,
    $core.double? heading,
    $fixnum.Int64? recordedAt,
  }) {
    final result = create();
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (accuracy != null) result.accuracy = accuracy;
    if (speed != null) result.speed = speed;
    if (altitude != null) result.altitude = altitude;
    if (heading != null) result.heading = heading;
    if (recordedAt != null) result.recordedAt = recordedAt;
    return result;
  }

  LocationPoint._();

  factory LocationPoint.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LocationPoint.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LocationPoint',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'latitude')
    ..aD(2, _omitFieldNames ? '' : 'longitude')
    ..aD(3, _omitFieldNames ? '' : 'accuracy', fieldType: $pb.PbFieldType.OF)
    ..aD(4, _omitFieldNames ? '' : 'speed', fieldType: $pb.PbFieldType.OF)
    ..aD(5, _omitFieldNames ? '' : 'altitude', fieldType: $pb.PbFieldType.OF)
    ..aD(6, _omitFieldNames ? '' : 'heading', fieldType: $pb.PbFieldType.OF)
    ..aInt64(7, _omitFieldNames ? '' : 'recordedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LocationPoint clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LocationPoint copyWith(void Function(LocationPoint) updates) =>
      super.copyWith((message) => updates(message as LocationPoint))
          as LocationPoint;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LocationPoint create() => LocationPoint._();
  @$core.override
  LocationPoint createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LocationPoint getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LocationPoint>(create);
  static LocationPoint? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get latitude => $_getN(0);
  @$pb.TagNumber(1)
  set latitude($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLatitude() => $_has(0);
  @$pb.TagNumber(1)
  void clearLatitude() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get longitude => $_getN(1);
  @$pb.TagNumber(2)
  set longitude($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLongitude() => $_has(1);
  @$pb.TagNumber(2)
  void clearLongitude() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get accuracy => $_getN(2);
  @$pb.TagNumber(3)
  set accuracy($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAccuracy() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccuracy() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get speed => $_getN(3);
  @$pb.TagNumber(4)
  set speed($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSpeed() => $_has(3);
  @$pb.TagNumber(4)
  void clearSpeed() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get altitude => $_getN(4);
  @$pb.TagNumber(5)
  set altitude($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAltitude() => $_has(4);
  @$pb.TagNumber(5)
  void clearAltitude() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get heading => $_getN(5);
  @$pb.TagNumber(6)
  set heading($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHeading() => $_has(5);
  @$pb.TagNumber(6)
  void clearHeading() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get recordedAt => $_getI64(6);
  @$pb.TagNumber(7)
  set recordedAt($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRecordedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearRecordedAt() => $_clearField(7);
}

class StartJourneyRequest extends $pb.GeneratedMessage {
  factory StartJourneyRequest({
    $core.String? deviceId,
    $core.String? label,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    if (label != null) result.label = label;
    return result;
  }

  StartJourneyRequest._();

  factory StartJourneyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StartJourneyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StartJourneyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartJourneyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartJourneyRequest copyWith(void Function(StartJourneyRequest) updates) =>
      super.copyWith((message) => updates(message as StartJourneyRequest))
          as StartJourneyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartJourneyRequest create() => StartJourneyRequest._();
  @$core.override
  StartJourneyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StartJourneyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StartJourneyRequest>(create);
  static StartJourneyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);
}

class EndJourneyRequest extends $pb.GeneratedMessage {
  factory EndJourneyRequest({
    $core.String? journeyId,
  }) {
    final result = create();
    if (journeyId != null) result.journeyId = journeyId;
    return result;
  }

  EndJourneyRequest._();

  factory EndJourneyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EndJourneyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EndJourneyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'journeyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EndJourneyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EndJourneyRequest copyWith(void Function(EndJourneyRequest) updates) =>
      super.copyWith((message) => updates(message as EndJourneyRequest))
          as EndJourneyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EndJourneyRequest create() => EndJourneyRequest._();
  @$core.override
  EndJourneyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EndJourneyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EndJourneyRequest>(create);
  static EndJourneyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get journeyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set journeyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasJourneyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearJourneyId() => $_clearField(1);
}

class Journey extends $pb.GeneratedMessage {
  factory Journey({
    $core.String? id,
    $core.String? deviceId,
    $core.String? label,
    $fixnum.Int64? startedAt,
    $fixnum.Int64? endedAt,
    $core.double? totalDistanceM,
    $core.int? pointCount,
    $core.String? transportMode,
    $core.String? startPlace,
    $core.String? endPlace,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (deviceId != null) result.deviceId = deviceId;
    if (label != null) result.label = label;
    if (startedAt != null) result.startedAt = startedAt;
    if (endedAt != null) result.endedAt = endedAt;
    if (totalDistanceM != null) result.totalDistanceM = totalDistanceM;
    if (pointCount != null) result.pointCount = pointCount;
    if (transportMode != null) result.transportMode = transportMode;
    if (startPlace != null) result.startPlace = startPlace;
    if (endPlace != null) result.endPlace = endPlace;
    return result;
  }

  Journey._();

  factory Journey.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Journey.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Journey',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'deviceId')
    ..aOS(3, _omitFieldNames ? '' : 'label')
    ..aInt64(4, _omitFieldNames ? '' : 'startedAt')
    ..aInt64(5, _omitFieldNames ? '' : 'endedAt')
    ..aD(6, _omitFieldNames ? '' : 'totalDistanceM')
    ..aI(7, _omitFieldNames ? '' : 'pointCount')
    ..aOS(8, _omitFieldNames ? '' : 'transportMode')
    ..aOS(9, _omitFieldNames ? '' : 'startPlace')
    ..aOS(10, _omitFieldNames ? '' : 'endPlace')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Journey clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Journey copyWith(void Function(Journey) updates) =>
      super.copyWith((message) => updates(message as Journey)) as Journey;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Journey create() => Journey._();
  @$core.override
  Journey createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Journey getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Journey>(create);
  static Journey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get label => $_getSZ(2);
  @$pb.TagNumber(3)
  set label($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLabel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabel() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get startedAt => $_getI64(3);
  @$pb.TagNumber(4)
  set startedAt($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStartedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearStartedAt() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get endedAt => $_getI64(4);
  @$pb.TagNumber(5)
  set endedAt($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEndedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearEndedAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get totalDistanceM => $_getN(5);
  @$pb.TagNumber(6)
  set totalDistanceM($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTotalDistanceM() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalDistanceM() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get pointCount => $_getIZ(6);
  @$pb.TagNumber(7)
  set pointCount($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPointCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearPointCount() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get transportMode => $_getSZ(7);
  @$pb.TagNumber(8)
  set transportMode($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTransportMode() => $_has(7);
  @$pb.TagNumber(8)
  void clearTransportMode() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get startPlace => $_getSZ(8);
  @$pb.TagNumber(9)
  set startPlace($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasStartPlace() => $_has(8);
  @$pb.TagNumber(9)
  void clearStartPlace() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get endPlace => $_getSZ(9);
  @$pb.TagNumber(10)
  set endPlace($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasEndPlace() => $_has(9);
  @$pb.TagNumber(10)
  void clearEndPlace() => $_clearField(10);
}

class GetJourneysRequest extends $pb.GeneratedMessage {
  factory GetJourneysRequest({
    $core.String? deviceId,
    $core.int? limit,
    $core.int? offset,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    if (limit != null) result.limit = limit;
    if (offset != null) result.offset = offset;
    return result;
  }

  GetJourneysRequest._();

  factory GetJourneysRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetJourneysRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetJourneysRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..aI(2, _omitFieldNames ? '' : 'limit')
    ..aI(3, _omitFieldNames ? '' : 'offset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetJourneysRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetJourneysRequest copyWith(void Function(GetJourneysRequest) updates) =>
      super.copyWith((message) => updates(message as GetJourneysRequest))
          as GetJourneysRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetJourneysRequest create() => GetJourneysRequest._();
  @$core.override
  GetJourneysRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetJourneysRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetJourneysRequest>(create);
  static GetJourneysRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get offset => $_getIZ(2);
  @$pb.TagNumber(3)
  set offset($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOffset() => $_has(2);
  @$pb.TagNumber(3)
  void clearOffset() => $_clearField(3);
}

class GetJourneysResponse extends $pb.GeneratedMessage {
  factory GetJourneysResponse({
    $core.Iterable<Journey>? journeys,
    $core.int? total,
  }) {
    final result = create();
    if (journeys != null) result.journeys.addAll(journeys);
    if (total != null) result.total = total;
    return result;
  }

  GetJourneysResponse._();

  factory GetJourneysResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetJourneysResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetJourneysResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..pPM<Journey>(1, _omitFieldNames ? '' : 'journeys',
        subBuilder: Journey.create)
    ..aI(2, _omitFieldNames ? '' : 'total')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetJourneysResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetJourneysResponse copyWith(void Function(GetJourneysResponse) updates) =>
      super.copyWith((message) => updates(message as GetJourneysResponse))
          as GetJourneysResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetJourneysResponse create() => GetJourneysResponse._();
  @$core.override
  GetJourneysResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetJourneysResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetJourneysResponse>(create);
  static GetJourneysResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Journey> get journeys => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get total => $_getIZ(1);
  @$pb.TagNumber(2)
  set total($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => $_clearField(2);
}

class GetJourneyPointsRequest extends $pb.GeneratedMessage {
  factory GetJourneyPointsRequest({
    $core.String? journeyId,
  }) {
    final result = create();
    if (journeyId != null) result.journeyId = journeyId;
    return result;
  }

  GetJourneyPointsRequest._();

  factory GetJourneyPointsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetJourneyPointsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetJourneyPointsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'journeyId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetJourneyPointsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetJourneyPointsRequest copyWith(
          void Function(GetJourneyPointsRequest) updates) =>
      super.copyWith((message) => updates(message as GetJourneyPointsRequest))
          as GetJourneyPointsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetJourneyPointsRequest create() => GetJourneyPointsRequest._();
  @$core.override
  GetJourneyPointsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetJourneyPointsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetJourneyPointsRequest>(create);
  static GetJourneyPointsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get journeyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set journeyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasJourneyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearJourneyId() => $_clearField(1);
}

class GetJourneyPointsResponse extends $pb.GeneratedMessage {
  factory GetJourneyPointsResponse({
    $core.Iterable<LocationPoint>? points,
  }) {
    final result = create();
    if (points != null) result.points.addAll(points);
    return result;
  }

  GetJourneyPointsResponse._();

  factory GetJourneyPointsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetJourneyPointsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetJourneyPointsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..pPM<LocationPoint>(1, _omitFieldNames ? '' : 'points',
        subBuilder: LocationPoint.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetJourneyPointsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetJourneyPointsResponse copyWith(
          void Function(GetJourneyPointsResponse) updates) =>
      super.copyWith((message) => updates(message as GetJourneyPointsResponse))
          as GetJourneyPointsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetJourneyPointsResponse create() => GetJourneyPointsResponse._();
  @$core.override
  GetJourneyPointsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetJourneyPointsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetJourneyPointsResponse>(create);
  static GetJourneyPointsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LocationPoint> get points => $_getList(0);
}

class DeviceCodeRequest extends $pb.GeneratedMessage {
  factory DeviceCodeRequest({
    $core.String? deviceName,
    $core.String? platform,
  }) {
    final result = create();
    if (deviceName != null) result.deviceName = deviceName;
    if (platform != null) result.platform = platform;
    return result;
  }

  DeviceCodeRequest._();

  factory DeviceCodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeviceCodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeviceCodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceName')
    ..aOS(2, _omitFieldNames ? '' : 'platform')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceCodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceCodeRequest copyWith(void Function(DeviceCodeRequest) updates) =>
      super.copyWith((message) => updates(message as DeviceCodeRequest))
          as DeviceCodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeviceCodeRequest create() => DeviceCodeRequest._();
  @$core.override
  DeviceCodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeviceCodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeviceCodeRequest>(create);
  static DeviceCodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceName => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceName() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get platform => $_getSZ(1);
  @$pb.TagNumber(2)
  set platform($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPlatform() => $_has(1);
  @$pb.TagNumber(2)
  void clearPlatform() => $_clearField(2);
}

class DeviceCodeResponse extends $pb.GeneratedMessage {
  factory DeviceCodeResponse({
    $core.String? deviceCode,
    $fixnum.Int64? expiresAt,
    $core.int? interval,
  }) {
    final result = create();
    if (deviceCode != null) result.deviceCode = deviceCode;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (interval != null) result.interval = interval;
    return result;
  }

  DeviceCodeResponse._();

  factory DeviceCodeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeviceCodeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeviceCodeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceCode')
    ..aInt64(2, _omitFieldNames ? '' : 'expiresAt')
    ..aI(3, _omitFieldNames ? '' : 'interval')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceCodeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceCodeResponse copyWith(void Function(DeviceCodeResponse) updates) =>
      super.copyWith((message) => updates(message as DeviceCodeResponse))
          as DeviceCodeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeviceCodeResponse create() => DeviceCodeResponse._();
  @$core.override
  DeviceCodeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeviceCodeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeviceCodeResponse>(create);
  static DeviceCodeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceCode => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceCode($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expiresAt => $_getI64(1);
  @$pb.TagNumber(2)
  set expiresAt($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpiresAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpiresAt() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get interval => $_getIZ(2);
  @$pb.TagNumber(3)
  set interval($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasInterval() => $_has(2);
  @$pb.TagNumber(3)
  void clearInterval() => $_clearField(3);
}

class PollActivationRequest extends $pb.GeneratedMessage {
  factory PollActivationRequest({
    $core.String? deviceCode,
  }) {
    final result = create();
    if (deviceCode != null) result.deviceCode = deviceCode;
    return result;
  }

  PollActivationRequest._();

  factory PollActivationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PollActivationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PollActivationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceCode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PollActivationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PollActivationRequest copyWith(
          void Function(PollActivationRequest) updates) =>
      super.copyWith((message) => updates(message as PollActivationRequest))
          as PollActivationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PollActivationRequest create() => PollActivationRequest._();
  @$core.override
  PollActivationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PollActivationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PollActivationRequest>(create);
  static PollActivationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceCode => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceCode($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceCode() => $_clearField(1);
}

class DeviceActivationResponse extends $pb.GeneratedMessage {
  factory DeviceActivationResponse({
    $core.bool? activated,
    $core.String? deviceToken,
    $core.String? deviceId,
    $core.String? deviceName,
  }) {
    final result = create();
    if (activated != null) result.activated = activated;
    if (deviceToken != null) result.deviceToken = deviceToken;
    if (deviceId != null) result.deviceId = deviceId;
    if (deviceName != null) result.deviceName = deviceName;
    return result;
  }

  DeviceActivationResponse._();

  factory DeviceActivationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeviceActivationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeviceActivationResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'activated')
    ..aOS(2, _omitFieldNames ? '' : 'deviceToken')
    ..aOS(3, _omitFieldNames ? '' : 'deviceId')
    ..aOS(4, _omitFieldNames ? '' : 'deviceName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceActivationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceActivationResponse copyWith(
          void Function(DeviceActivationResponse) updates) =>
      super.copyWith((message) => updates(message as DeviceActivationResponse))
          as DeviceActivationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeviceActivationResponse create() => DeviceActivationResponse._();
  @$core.override
  DeviceActivationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeviceActivationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeviceActivationResponse>(create);
  static DeviceActivationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get activated => $_getBF(0);
  @$pb.TagNumber(1)
  set activated($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasActivated() => $_has(0);
  @$pb.TagNumber(1)
  void clearActivated() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get deviceId => $_getSZ(2);
  @$pb.TagNumber(3)
  set deviceId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get deviceName => $_getSZ(3);
  @$pb.TagNumber(4)
  set deviceName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDeviceName() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeviceName() => $_clearField(4);
}

class GetJourneyStatsRequest extends $pb.GeneratedMessage {
  factory GetJourneyStatsRequest({
    $core.String? deviceId,
    $core.String? period,
    $core.int? limit,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    if (period != null) result.period = period;
    if (limit != null) result.limit = limit;
    return result;
  }

  GetJourneyStatsRequest._();

  factory GetJourneyStatsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetJourneyStatsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetJourneyStatsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..aOS(2, _omitFieldNames ? '' : 'period')
    ..aI(3, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetJourneyStatsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetJourneyStatsRequest copyWith(
          void Function(GetJourneyStatsRequest) updates) =>
      super.copyWith((message) => updates(message as GetJourneyStatsRequest))
          as GetJourneyStatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetJourneyStatsRequest create() => GetJourneyStatsRequest._();
  @$core.override
  GetJourneyStatsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetJourneyStatsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetJourneyStatsRequest>(create);
  static GetJourneyStatsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get period => $_getSZ(1);
  @$pb.TagNumber(2)
  set period($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPeriod() => $_has(1);
  @$pb.TagNumber(2)
  void clearPeriod() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);
}

class JourneyStats extends $pb.GeneratedMessage {
  factory JourneyStats({
    $core.String? deviceId,
    $core.int? totalJourneys,
    $core.double? totalDistanceM,
    $fixnum.Int64? totalDurationMs,
    $core.double? avgSpeed,
    $core.double? maxSpeed,
    $core.double? avgDistancePerJourney,
    $core.Iterable<DayStats>? daily,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    if (totalJourneys != null) result.totalJourneys = totalJourneys;
    if (totalDistanceM != null) result.totalDistanceM = totalDistanceM;
    if (totalDurationMs != null) result.totalDurationMs = totalDurationMs;
    if (avgSpeed != null) result.avgSpeed = avgSpeed;
    if (maxSpeed != null) result.maxSpeed = maxSpeed;
    if (avgDistancePerJourney != null)
      result.avgDistancePerJourney = avgDistancePerJourney;
    if (daily != null) result.daily.addAll(daily);
    return result;
  }

  JourneyStats._();

  factory JourneyStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory JourneyStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'JourneyStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..aI(2, _omitFieldNames ? '' : 'totalJourneys')
    ..aD(3, _omitFieldNames ? '' : 'totalDistanceM')
    ..aInt64(4, _omitFieldNames ? '' : 'totalDurationMs')
    ..aD(5, _omitFieldNames ? '' : 'avgSpeed')
    ..aD(6, _omitFieldNames ? '' : 'maxSpeed')
    ..aD(7, _omitFieldNames ? '' : 'avgDistancePerJourney')
    ..pPM<DayStats>(8, _omitFieldNames ? '' : 'daily',
        subBuilder: DayStats.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JourneyStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  JourneyStats copyWith(void Function(JourneyStats) updates) =>
      super.copyWith((message) => updates(message as JourneyStats))
          as JourneyStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JourneyStats create() => JourneyStats._();
  @$core.override
  JourneyStats createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static JourneyStats getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<JourneyStats>(create);
  static JourneyStats? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get totalJourneys => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalJourneys($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalJourneys() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalJourneys() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get totalDistanceM => $_getN(2);
  @$pb.TagNumber(3)
  set totalDistanceM($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalDistanceM() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalDistanceM() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get totalDurationMs => $_getI64(3);
  @$pb.TagNumber(4)
  set totalDurationMs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTotalDurationMs() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalDurationMs() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get avgSpeed => $_getN(4);
  @$pb.TagNumber(5)
  set avgSpeed($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAvgSpeed() => $_has(4);
  @$pb.TagNumber(5)
  void clearAvgSpeed() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get maxSpeed => $_getN(5);
  @$pb.TagNumber(6)
  set maxSpeed($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxSpeed() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxSpeed() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get avgDistancePerJourney => $_getN(6);
  @$pb.TagNumber(7)
  set avgDistancePerJourney($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAvgDistancePerJourney() => $_has(6);
  @$pb.TagNumber(7)
  void clearAvgDistancePerJourney() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<DayStats> get daily => $_getList(7);
}

class DayStats extends $pb.GeneratedMessage {
  factory DayStats({
    $core.String? date,
    $core.int? journeyCount,
    $core.double? distanceM,
    $fixnum.Int64? durationMs,
  }) {
    final result = create();
    if (date != null) result.date = date;
    if (journeyCount != null) result.journeyCount = journeyCount;
    if (distanceM != null) result.distanceM = distanceM;
    if (durationMs != null) result.durationMs = durationMs;
    return result;
  }

  DayStats._();

  factory DayStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DayStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DayStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'date')
    ..aI(2, _omitFieldNames ? '' : 'journeyCount')
    ..aD(3, _omitFieldNames ? '' : 'distanceM')
    ..aInt64(4, _omitFieldNames ? '' : 'durationMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DayStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DayStats copyWith(void Function(DayStats) updates) =>
      super.copyWith((message) => updates(message as DayStats)) as DayStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DayStats create() => DayStats._();
  @$core.override
  DayStats createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DayStats getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DayStats>(create);
  static DayStats? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get date => $_getSZ(0);
  @$pb.TagNumber(1)
  set date($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearDate() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get journeyCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set journeyCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasJourneyCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearJourneyCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get distanceM => $_getN(2);
  @$pb.TagNumber(3)
  set distanceM($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDistanceM() => $_has(2);
  @$pb.TagNumber(3)
  void clearDistanceM() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get durationMs => $_getI64(3);
  @$pb.TagNumber(4)
  set durationMs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDurationMs() => $_has(3);
  @$pb.TagNumber(4)
  void clearDurationMs() => $_clearField(4);
}

class SaveLocationRequest extends $pb.GeneratedMessage {
  factory SaveLocationRequest({
    $core.String? deviceId,
    $core.String? name,
    $core.double? latitude,
    $core.double? longitude,
    $core.double? radiusM,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    if (name != null) result.name = name;
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (radiusM != null) result.radiusM = radiusM;
    return result;
  }

  SaveLocationRequest._();

  factory SaveLocationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SaveLocationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SaveLocationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aD(3, _omitFieldNames ? '' : 'latitude')
    ..aD(4, _omitFieldNames ? '' : 'longitude')
    ..aD(5, _omitFieldNames ? '' : 'radiusM', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveLocationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveLocationRequest copyWith(void Function(SaveLocationRequest) updates) =>
      super.copyWith((message) => updates(message as SaveLocationRequest))
          as SaveLocationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SaveLocationRequest create() => SaveLocationRequest._();
  @$core.override
  SaveLocationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SaveLocationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SaveLocationRequest>(create);
  static SaveLocationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get latitude => $_getN(2);
  @$pb.TagNumber(3)
  set latitude($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLatitude() => $_has(2);
  @$pb.TagNumber(3)
  void clearLatitude() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get longitude => $_getN(3);
  @$pb.TagNumber(4)
  set longitude($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLongitude() => $_has(3);
  @$pb.TagNumber(4)
  void clearLongitude() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get radiusM => $_getN(4);
  @$pb.TagNumber(5)
  set radiusM($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRadiusM() => $_has(4);
  @$pb.TagNumber(5)
  void clearRadiusM() => $_clearField(5);
}

class SavedLocation extends $pb.GeneratedMessage {
  factory SavedLocation({
    $core.String? id,
    $core.String? deviceId,
    $core.String? name,
    $core.double? latitude,
    $core.double? longitude,
    $core.double? radiusM,
    $fixnum.Int64? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (deviceId != null) result.deviceId = deviceId;
    if (name != null) result.name = name;
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (radiusM != null) result.radiusM = radiusM;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  SavedLocation._();

  factory SavedLocation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SavedLocation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SavedLocation',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'deviceId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aD(4, _omitFieldNames ? '' : 'latitude')
    ..aD(5, _omitFieldNames ? '' : 'longitude')
    ..aD(6, _omitFieldNames ? '' : 'radiusM', fieldType: $pb.PbFieldType.OF)
    ..aInt64(7, _omitFieldNames ? '' : 'createdAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavedLocation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SavedLocation copyWith(void Function(SavedLocation) updates) =>
      super.copyWith((message) => updates(message as SavedLocation))
          as SavedLocation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SavedLocation create() => SavedLocation._();
  @$core.override
  SavedLocation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SavedLocation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SavedLocation>(create);
  static SavedLocation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get deviceId => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get latitude => $_getN(3);
  @$pb.TagNumber(4)
  set latitude($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLatitude() => $_has(3);
  @$pb.TagNumber(4)
  void clearLatitude() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get longitude => $_getN(4);
  @$pb.TagNumber(5)
  set longitude($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLongitude() => $_has(4);
  @$pb.TagNumber(5)
  void clearLongitude() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get radiusM => $_getN(5);
  @$pb.TagNumber(6)
  set radiusM($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRadiusM() => $_has(5);
  @$pb.TagNumber(6)
  void clearRadiusM() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get createdAt => $_getI64(6);
  @$pb.TagNumber(7)
  set createdAt($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => $_clearField(7);
}

class GetSavedLocationsRequest extends $pb.GeneratedMessage {
  factory GetSavedLocationsRequest({
    $core.String? deviceId,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    return result;
  }

  GetSavedLocationsRequest._();

  factory GetSavedLocationsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSavedLocationsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSavedLocationsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSavedLocationsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSavedLocationsRequest copyWith(
          void Function(GetSavedLocationsRequest) updates) =>
      super.copyWith((message) => updates(message as GetSavedLocationsRequest))
          as GetSavedLocationsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSavedLocationsRequest create() => GetSavedLocationsRequest._();
  @$core.override
  GetSavedLocationsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSavedLocationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSavedLocationsRequest>(create);
  static GetSavedLocationsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);
}

class GetSavedLocationsResponse extends $pb.GeneratedMessage {
  factory GetSavedLocationsResponse({
    $core.Iterable<SavedLocation>? locations,
  }) {
    final result = create();
    if (locations != null) result.locations.addAll(locations);
    return result;
  }

  GetSavedLocationsResponse._();

  factory GetSavedLocationsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSavedLocationsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSavedLocationsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..pPM<SavedLocation>(1, _omitFieldNames ? '' : 'locations',
        subBuilder: SavedLocation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSavedLocationsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSavedLocationsResponse copyWith(
          void Function(GetSavedLocationsResponse) updates) =>
      super.copyWith((message) => updates(message as GetSavedLocationsResponse))
          as GetSavedLocationsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSavedLocationsResponse create() => GetSavedLocationsResponse._();
  @$core.override
  GetSavedLocationsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSavedLocationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSavedLocationsResponse>(create);
  static GetSavedLocationsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SavedLocation> get locations => $_getList(0);
}

class DeleteSavedLocationRequest extends $pb.GeneratedMessage {
  factory DeleteSavedLocationRequest({
    $core.String? locationId,
  }) {
    final result = create();
    if (locationId != null) result.locationId = locationId;
    return result;
  }

  DeleteSavedLocationRequest._();

  factory DeleteSavedLocationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteSavedLocationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteSavedLocationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'locationId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteSavedLocationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteSavedLocationRequest copyWith(
          void Function(DeleteSavedLocationRequest) updates) =>
      super.copyWith(
              (message) => updates(message as DeleteSavedLocationRequest))
          as DeleteSavedLocationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteSavedLocationRequest create() => DeleteSavedLocationRequest._();
  @$core.override
  DeleteSavedLocationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteSavedLocationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteSavedLocationRequest>(create);
  static DeleteSavedLocationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get locationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set locationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLocationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLocationId() => $_clearField(1);
}

class CreateShareLinkRequest extends $pb.GeneratedMessage {
  factory CreateShareLinkRequest({
    $core.String? journeyId,
    $fixnum.Int64? durationHours,
  }) {
    final result = create();
    if (journeyId != null) result.journeyId = journeyId;
    if (durationHours != null) result.durationHours = durationHours;
    return result;
  }

  CreateShareLinkRequest._();

  factory CreateShareLinkRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateShareLinkRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateShareLinkRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'journeyId')
    ..aInt64(2, _omitFieldNames ? '' : 'durationHours')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateShareLinkRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateShareLinkRequest copyWith(
          void Function(CreateShareLinkRequest) updates) =>
      super.copyWith((message) => updates(message as CreateShareLinkRequest))
          as CreateShareLinkRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateShareLinkRequest create() => CreateShareLinkRequest._();
  @$core.override
  CreateShareLinkRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateShareLinkRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateShareLinkRequest>(create);
  static CreateShareLinkRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get journeyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set journeyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasJourneyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearJourneyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get durationHours => $_getI64(1);
  @$pb.TagNumber(2)
  set durationHours($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDurationHours() => $_has(1);
  @$pb.TagNumber(2)
  void clearDurationHours() => $_clearField(2);
}

class ShareLink extends $pb.GeneratedMessage {
  factory ShareLink({
    $core.String? id,
    $core.String? journeyId,
    $core.String? url,
    $fixnum.Int64? expiresAt,
    $core.bool? expired,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (journeyId != null) result.journeyId = journeyId;
    if (url != null) result.url = url;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (expired != null) result.expired = expired;
    return result;
  }

  ShareLink._();

  factory ShareLink.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ShareLink.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ShareLink',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'journeyId')
    ..aOS(3, _omitFieldNames ? '' : 'url')
    ..aInt64(4, _omitFieldNames ? '' : 'expiresAt')
    ..aOB(5, _omitFieldNames ? '' : 'expired')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShareLink clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ShareLink copyWith(void Function(ShareLink) updates) =>
      super.copyWith((message) => updates(message as ShareLink)) as ShareLink;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ShareLink create() => ShareLink._();
  @$core.override
  ShareLink createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ShareLink getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ShareLink>(create);
  static ShareLink? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get journeyId => $_getSZ(1);
  @$pb.TagNumber(2)
  set journeyId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasJourneyId() => $_has(1);
  @$pb.TagNumber(2)
  void clearJourneyId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get url => $_getSZ(2);
  @$pb.TagNumber(3)
  set url($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get expiresAt => $_getI64(3);
  @$pb.TagNumber(4)
  set expiresAt($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpiresAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpiresAt() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get expired => $_getBF(4);
  @$pb.TagNumber(5)
  set expired($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExpired() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpired() => $_clearField(5);
}

class GetShareLinkRequest extends $pb.GeneratedMessage {
  factory GetShareLinkRequest({
    $core.String? shareId,
  }) {
    final result = create();
    if (shareId != null) result.shareId = shareId;
    return result;
  }

  GetShareLinkRequest._();

  factory GetShareLinkRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetShareLinkRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetShareLinkRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'shareId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetShareLinkRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetShareLinkRequest copyWith(void Function(GetShareLinkRequest) updates) =>
      super.copyWith((message) => updates(message as GetShareLinkRequest))
          as GetShareLinkRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetShareLinkRequest create() => GetShareLinkRequest._();
  @$core.override
  GetShareLinkRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetShareLinkRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetShareLinkRequest>(create);
  static GetShareLinkRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get shareId => $_getSZ(0);
  @$pb.TagNumber(1)
  set shareId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasShareId() => $_has(0);
  @$pb.TagNumber(1)
  void clearShareId() => $_clearField(1);
}

class ExportRequest extends $pb.GeneratedMessage {
  factory ExportRequest({
    $core.String? journeyId,
    $core.String? format,
  }) {
    final result = create();
    if (journeyId != null) result.journeyId = journeyId;
    if (format != null) result.format = format;
    return result;
  }

  ExportRequest._();

  factory ExportRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExportRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'journeyId')
    ..aOS(2, _omitFieldNames ? '' : 'format')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportRequest copyWith(void Function(ExportRequest) updates) =>
      super.copyWith((message) => updates(message as ExportRequest))
          as ExportRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExportRequest create() => ExportRequest._();
  @$core.override
  ExportRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExportRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportRequest>(create);
  static ExportRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get journeyId => $_getSZ(0);
  @$pb.TagNumber(1)
  set journeyId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasJourneyId() => $_has(0);
  @$pb.TagNumber(1)
  void clearJourneyId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get format => $_getSZ(1);
  @$pb.TagNumber(2)
  set format($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFormat() => $_has(1);
  @$pb.TagNumber(2)
  void clearFormat() => $_clearField(2);
}

class ExportResponse extends $pb.GeneratedMessage {
  factory ExportResponse({
    $core.String? filename,
    $core.List<$core.int>? data,
  }) {
    final result = create();
    if (filename != null) result.filename = filename;
    if (data != null) result.data = data;
    return result;
  }

  ExportResponse._();

  factory ExportResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExportResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'filename')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportResponse copyWith(void Function(ExportResponse) updates) =>
      super.copyWith((message) => updates(message as ExportResponse))
          as ExportResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExportResponse create() => ExportResponse._();
  @$core.override
  ExportResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExportResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportResponse>(create);
  static ExportResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filename => $_getSZ(0);
  @$pb.TagNumber(1)
  set filename($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFilename() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilename() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => $_clearField(2);
}

class Device extends $pb.GeneratedMessage {
  factory Device({
    $core.String? id,
    $core.String? name,
    $core.String? platform,
    $fixnum.Int64? lastSeen,
    $core.bool? active,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (platform != null) result.platform = platform;
    if (lastSeen != null) result.lastSeen = lastSeen;
    if (active != null) result.active = active;
    return result;
  }

  Device._();

  factory Device.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Device.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Device',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'platform')
    ..aInt64(4, _omitFieldNames ? '' : 'lastSeen')
    ..aOB(5, _omitFieldNames ? '' : 'active')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Device clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Device copyWith(void Function(Device) updates) =>
      super.copyWith((message) => updates(message as Device)) as Device;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Device create() => Device._();
  @$core.override
  Device createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Device getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Device>(create);
  static Device? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get platform => $_getSZ(2);
  @$pb.TagNumber(3)
  set platform($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPlatform() => $_has(2);
  @$pb.TagNumber(3)
  void clearPlatform() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get lastSeen => $_getI64(3);
  @$pb.TagNumber(4)
  set lastSeen($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLastSeen() => $_has(3);
  @$pb.TagNumber(4)
  void clearLastSeen() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get active => $_getBF(4);
  @$pb.TagNumber(5)
  set active($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasActive() => $_has(4);
  @$pb.TagNumber(5)
  void clearActive() => $_clearField(5);
}

class GetDevicesRequest extends $pb.GeneratedMessage {
  factory GetDevicesRequest() => create();

  GetDevicesRequest._();

  factory GetDevicesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDevicesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDevicesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDevicesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDevicesRequest copyWith(void Function(GetDevicesRequest) updates) =>
      super.copyWith((message) => updates(message as GetDevicesRequest))
          as GetDevicesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDevicesRequest create() => GetDevicesRequest._();
  @$core.override
  GetDevicesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDevicesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDevicesRequest>(create);
  static GetDevicesRequest? _defaultInstance;
}

class GetDevicesResponse extends $pb.GeneratedMessage {
  factory GetDevicesResponse({
    $core.Iterable<Device>? devices,
  }) {
    final result = create();
    if (devices != null) result.devices.addAll(devices);
    return result;
  }

  GetDevicesResponse._();

  factory GetDevicesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDevicesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDevicesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..pPM<Device>(1, _omitFieldNames ? '' : 'devices',
        subBuilder: Device.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDevicesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDevicesResponse copyWith(void Function(GetDevicesResponse) updates) =>
      super.copyWith((message) => updates(message as GetDevicesResponse))
          as GetDevicesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDevicesResponse create() => GetDevicesResponse._();
  @$core.override
  GetDevicesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDevicesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDevicesResponse>(create);
  static GetDevicesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Device> get devices => $_getList(0);
}

class Empty extends $pb.GeneratedMessage {
  factory Empty() => create();

  Empty._();

  factory Empty.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Empty.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Empty',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'location.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Empty clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Empty copyWith(void Function(Empty) updates) =>
      super.copyWith((message) => updates(message as Empty)) as Empty;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Empty create() => Empty._();
  @$core.override
  Empty createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Empty getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Empty>(create);
  static Empty? _defaultInstance;
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
