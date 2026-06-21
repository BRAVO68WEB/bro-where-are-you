// This is a generated file - do not edit.
//
// Generated from location/v1/location.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use locationUpdateDescriptor instead')
const LocationUpdate$json = {
  '1': 'LocationUpdate',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'journey_id', '3': 2, '4': 1, '5': 9, '10': 'journeyId'},
    {'1': 'latitude', '3': 3, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 4, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'accuracy', '3': 5, '4': 1, '5': 2, '10': 'accuracy'},
    {'1': 'speed', '3': 6, '4': 1, '5': 2, '10': 'speed'},
    {'1': 'altitude', '3': 7, '4': 1, '5': 2, '10': 'altitude'},
    {'1': 'heading', '3': 8, '4': 1, '5': 2, '10': 'heading'},
    {'1': 'timestamp_ms', '3': 9, '4': 1, '5': 3, '10': 'timestampMs'},
    {'1': 'source', '3': 10, '4': 1, '5': 9, '10': 'source'},
    {'1': 'heart_rate', '3': 11, '4': 1, '5': 2, '10': 'heartRate'},
    {'1': 'transport_mode', '3': 12, '4': 1, '5': 9, '10': 'transportMode'},
  ],
};

/// Descriptor for `LocationUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List locationUpdateDescriptor = $convert.base64Decode(
    'Cg5Mb2NhdGlvblVwZGF0ZRIbCglkZXZpY2VfaWQYASABKAlSCGRldmljZUlkEh0KCmpvdXJuZX'
    'lfaWQYAiABKAlSCWpvdXJuZXlJZBIaCghsYXRpdHVkZRgDIAEoAVIIbGF0aXR1ZGUSHAoJbG9u'
    'Z2l0dWRlGAQgASgBUglsb25naXR1ZGUSGgoIYWNjdXJhY3kYBSABKAJSCGFjY3VyYWN5EhQKBX'
    'NwZWVkGAYgASgCUgVzcGVlZBIaCghhbHRpdHVkZRgHIAEoAlIIYWx0aXR1ZGUSGAoHaGVhZGlu'
    'ZxgIIAEoAlIHaGVhZGluZxIhCgx0aW1lc3RhbXBfbXMYCSABKANSC3RpbWVzdGFtcE1zEhYKBn'
    'NvdXJjZRgKIAEoCVIGc291cmNlEh0KCmhlYXJ0X3JhdGUYCyABKAJSCWhlYXJ0UmF0ZRIlCg50'
    'cmFuc3BvcnRfbW9kZRgMIAEoCVINdHJhbnNwb3J0TW9kZQ==');

@$core.Deprecated('Use locationAckDescriptor instead')
const LocationAck$json = {
  '1': 'LocationAck',
  '2': [
    {'1': 'points_received', '3': 1, '4': 1, '5': 5, '10': 'pointsReceived'},
    {'1': 'journey_id', '3': 2, '4': 1, '5': 9, '10': 'journeyId'},
  ],
};

/// Descriptor for `LocationAck`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List locationAckDescriptor = $convert.base64Decode(
    'CgtMb2NhdGlvbkFjaxInCg9wb2ludHNfcmVjZWl2ZWQYASABKAVSDnBvaW50c1JlY2VpdmVkEh'
    '0KCmpvdXJuZXlfaWQYAiABKAlSCWpvdXJuZXlJZA==');

@$core.Deprecated('Use locationPointDescriptor instead')
const LocationPoint$json = {
  '1': 'LocationPoint',
  '2': [
    {'1': 'latitude', '3': 1, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 2, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'accuracy', '3': 3, '4': 1, '5': 2, '10': 'accuracy'},
    {'1': 'speed', '3': 4, '4': 1, '5': 2, '10': 'speed'},
    {'1': 'altitude', '3': 5, '4': 1, '5': 2, '10': 'altitude'},
    {'1': 'heading', '3': 6, '4': 1, '5': 2, '10': 'heading'},
    {'1': 'recorded_at', '3': 7, '4': 1, '5': 3, '10': 'recordedAt'},
  ],
};

/// Descriptor for `LocationPoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List locationPointDescriptor = $convert.base64Decode(
    'Cg1Mb2NhdGlvblBvaW50EhoKCGxhdGl0dWRlGAEgASgBUghsYXRpdHVkZRIcCglsb25naXR1ZG'
    'UYAiABKAFSCWxvbmdpdHVkZRIaCghhY2N1cmFjeRgDIAEoAlIIYWNjdXJhY3kSFAoFc3BlZWQY'
    'BCABKAJSBXNwZWVkEhoKCGFsdGl0dWRlGAUgASgCUghhbHRpdHVkZRIYCgdoZWFkaW5nGAYgAS'
    'gCUgdoZWFkaW5nEh8KC3JlY29yZGVkX2F0GAcgASgDUgpyZWNvcmRlZEF0');

@$core.Deprecated('Use startJourneyRequestDescriptor instead')
const StartJourneyRequest$json = {
  '1': 'StartJourneyRequest',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
  ],
};

/// Descriptor for `StartJourneyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List startJourneyRequestDescriptor = $convert.base64Decode(
    'ChNTdGFydEpvdXJuZXlSZXF1ZXN0EhsKCWRldmljZV9pZBgBIAEoCVIIZGV2aWNlSWQSFAoFbG'
    'FiZWwYAiABKAlSBWxhYmVs');

@$core.Deprecated('Use endJourneyRequestDescriptor instead')
const EndJourneyRequest$json = {
  '1': 'EndJourneyRequest',
  '2': [
    {'1': 'journey_id', '3': 1, '4': 1, '5': 9, '10': 'journeyId'},
  ],
};

/// Descriptor for `EndJourneyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List endJourneyRequestDescriptor = $convert.base64Decode(
    'ChFFbmRKb3VybmV5UmVxdWVzdBIdCgpqb3VybmV5X2lkGAEgASgJUglqb3VybmV5SWQ=');

@$core.Deprecated('Use journeyDescriptor instead')
const Journey$json = {
  '1': 'Journey',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'label', '3': 3, '4': 1, '5': 9, '10': 'label'},
    {'1': 'started_at', '3': 4, '4': 1, '5': 3, '10': 'startedAt'},
    {'1': 'ended_at', '3': 5, '4': 1, '5': 3, '10': 'endedAt'},
    {'1': 'total_distance_m', '3': 6, '4': 1, '5': 1, '10': 'totalDistanceM'},
    {'1': 'point_count', '3': 7, '4': 1, '5': 5, '10': 'pointCount'},
    {'1': 'transport_mode', '3': 8, '4': 1, '5': 9, '10': 'transportMode'},
    {'1': 'start_place', '3': 9, '4': 1, '5': 9, '10': 'startPlace'},
    {'1': 'end_place', '3': 10, '4': 1, '5': 9, '10': 'endPlace'},
  ],
};

/// Descriptor for `Journey`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List journeyDescriptor = $convert.base64Decode(
    'CgdKb3VybmV5Eg4KAmlkGAEgASgJUgJpZBIbCglkZXZpY2VfaWQYAiABKAlSCGRldmljZUlkEh'
    'QKBWxhYmVsGAMgASgJUgVsYWJlbBIdCgpzdGFydGVkX2F0GAQgASgDUglzdGFydGVkQXQSGQoI'
    'ZW5kZWRfYXQYBSABKANSB2VuZGVkQXQSKAoQdG90YWxfZGlzdGFuY2VfbRgGIAEoAVIOdG90YW'
    'xEaXN0YW5jZU0SHwoLcG9pbnRfY291bnQYByABKAVSCnBvaW50Q291bnQSJQoOdHJhbnNwb3J0'
    'X21vZGUYCCABKAlSDXRyYW5zcG9ydE1vZGUSHwoLc3RhcnRfcGxhY2UYCSABKAlSCnN0YXJ0UG'
    'xhY2USGwoJZW5kX3BsYWNlGAogASgJUghlbmRQbGFjZQ==');

@$core.Deprecated('Use getJourneysRequestDescriptor instead')
const GetJourneysRequest$json = {
  '1': 'GetJourneysRequest',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'limit', '3': 2, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'offset', '3': 3, '4': 1, '5': 5, '10': 'offset'},
  ],
};

/// Descriptor for `GetJourneysRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getJourneysRequestDescriptor = $convert.base64Decode(
    'ChJHZXRKb3VybmV5c1JlcXVlc3QSGwoJZGV2aWNlX2lkGAEgASgJUghkZXZpY2VJZBIUCgVsaW'
    '1pdBgCIAEoBVIFbGltaXQSFgoGb2Zmc2V0GAMgASgFUgZvZmZzZXQ=');

@$core.Deprecated('Use getJourneysResponseDescriptor instead')
const GetJourneysResponse$json = {
  '1': 'GetJourneysResponse',
  '2': [
    {
      '1': 'journeys',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.location.v1.Journey',
      '10': 'journeys'
    },
    {'1': 'total', '3': 2, '4': 1, '5': 5, '10': 'total'},
  ],
};

/// Descriptor for `GetJourneysResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getJourneysResponseDescriptor = $convert.base64Decode(
    'ChNHZXRKb3VybmV5c1Jlc3BvbnNlEjAKCGpvdXJuZXlzGAEgAygLMhQubG9jYXRpb24udjEuSm'
    '91cm5leVIIam91cm5leXMSFAoFdG90YWwYAiABKAVSBXRvdGFs');

@$core.Deprecated('Use getJourneyPointsRequestDescriptor instead')
const GetJourneyPointsRequest$json = {
  '1': 'GetJourneyPointsRequest',
  '2': [
    {'1': 'journey_id', '3': 1, '4': 1, '5': 9, '10': 'journeyId'},
  ],
};

/// Descriptor for `GetJourneyPointsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getJourneyPointsRequestDescriptor =
    $convert.base64Decode(
        'ChdHZXRKb3VybmV5UG9pbnRzUmVxdWVzdBIdCgpqb3VybmV5X2lkGAEgASgJUglqb3VybmV5SW'
        'Q=');

@$core.Deprecated('Use getJourneyPointsResponseDescriptor instead')
const GetJourneyPointsResponse$json = {
  '1': 'GetJourneyPointsResponse',
  '2': [
    {
      '1': 'points',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.location.v1.LocationPoint',
      '10': 'points'
    },
  ],
};

/// Descriptor for `GetJourneyPointsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getJourneyPointsResponseDescriptor =
    $convert.base64Decode(
        'ChhHZXRKb3VybmV5UG9pbnRzUmVzcG9uc2USMgoGcG9pbnRzGAEgAygLMhoubG9jYXRpb24udj'
        'EuTG9jYXRpb25Qb2ludFIGcG9pbnRz');

@$core.Deprecated('Use deviceCodeRequestDescriptor instead')
const DeviceCodeRequest$json = {
  '1': 'DeviceCodeRequest',
  '2': [
    {'1': 'device_name', '3': 1, '4': 1, '5': 9, '10': 'deviceName'},
    {'1': 'platform', '3': 2, '4': 1, '5': 9, '10': 'platform'},
  ],
};

/// Descriptor for `DeviceCodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceCodeRequestDescriptor = $convert.base64Decode(
    'ChFEZXZpY2VDb2RlUmVxdWVzdBIfCgtkZXZpY2VfbmFtZRgBIAEoCVIKZGV2aWNlTmFtZRIaCg'
    'hwbGF0Zm9ybRgCIAEoCVIIcGxhdGZvcm0=');

@$core.Deprecated('Use deviceCodeResponseDescriptor instead')
const DeviceCodeResponse$json = {
  '1': 'DeviceCodeResponse',
  '2': [
    {'1': 'device_code', '3': 1, '4': 1, '5': 9, '10': 'deviceCode'},
    {'1': 'expires_at', '3': 2, '4': 1, '5': 3, '10': 'expiresAt'},
    {'1': 'interval', '3': 3, '4': 1, '5': 5, '10': 'interval'},
  ],
};

/// Descriptor for `DeviceCodeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceCodeResponseDescriptor = $convert.base64Decode(
    'ChJEZXZpY2VDb2RlUmVzcG9uc2USHwoLZGV2aWNlX2NvZGUYASABKAlSCmRldmljZUNvZGUSHQ'
    'oKZXhwaXJlc19hdBgCIAEoA1IJZXhwaXJlc0F0EhoKCGludGVydmFsGAMgASgFUghpbnRlcnZh'
    'bA==');

@$core.Deprecated('Use pollActivationRequestDescriptor instead')
const PollActivationRequest$json = {
  '1': 'PollActivationRequest',
  '2': [
    {'1': 'device_code', '3': 1, '4': 1, '5': 9, '10': 'deviceCode'},
  ],
};

/// Descriptor for `PollActivationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pollActivationRequestDescriptor = $convert.base64Decode(
    'ChVQb2xsQWN0aXZhdGlvblJlcXVlc3QSHwoLZGV2aWNlX2NvZGUYASABKAlSCmRldmljZUNvZG'
    'U=');

@$core.Deprecated('Use deviceActivationResponseDescriptor instead')
const DeviceActivationResponse$json = {
  '1': 'DeviceActivationResponse',
  '2': [
    {'1': 'activated', '3': 1, '4': 1, '5': 8, '10': 'activated'},
    {'1': 'device_token', '3': 2, '4': 1, '5': 9, '10': 'deviceToken'},
    {'1': 'device_id', '3': 3, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'device_name', '3': 4, '4': 1, '5': 9, '10': 'deviceName'},
  ],
};

/// Descriptor for `DeviceActivationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceActivationResponseDescriptor = $convert.base64Decode(
    'ChhEZXZpY2VBY3RpdmF0aW9uUmVzcG9uc2USHAoJYWN0aXZhdGVkGAEgASgIUglhY3RpdmF0ZW'
    'QSIQoMZGV2aWNlX3Rva2VuGAIgASgJUgtkZXZpY2VUb2tlbhIbCglkZXZpY2VfaWQYAyABKAlS'
    'CGRldmljZUlkEh8KC2RldmljZV9uYW1lGAQgASgJUgpkZXZpY2VOYW1l');

@$core.Deprecated('Use getJourneyStatsRequestDescriptor instead')
const GetJourneyStatsRequest$json = {
  '1': 'GetJourneyStatsRequest',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'period', '3': 2, '4': 1, '5': 9, '10': 'period'},
    {'1': 'limit', '3': 3, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `GetJourneyStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getJourneyStatsRequestDescriptor =
    $convert.base64Decode(
        'ChZHZXRKb3VybmV5U3RhdHNSZXF1ZXN0EhsKCWRldmljZV9pZBgBIAEoCVIIZGV2aWNlSWQSFg'
        'oGcGVyaW9kGAIgASgJUgZwZXJpb2QSFAoFbGltaXQYAyABKAVSBWxpbWl0');

@$core.Deprecated('Use journeyStatsDescriptor instead')
const JourneyStats$json = {
  '1': 'JourneyStats',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'total_journeys', '3': 2, '4': 1, '5': 5, '10': 'totalJourneys'},
    {'1': 'total_distance_m', '3': 3, '4': 1, '5': 1, '10': 'totalDistanceM'},
    {'1': 'total_duration_ms', '3': 4, '4': 1, '5': 3, '10': 'totalDurationMs'},
    {'1': 'avg_speed', '3': 5, '4': 1, '5': 1, '10': 'avgSpeed'},
    {'1': 'max_speed', '3': 6, '4': 1, '5': 1, '10': 'maxSpeed'},
    {
      '1': 'avg_distance_per_journey',
      '3': 7,
      '4': 1,
      '5': 1,
      '10': 'avgDistancePerJourney'
    },
    {
      '1': 'daily',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.location.v1.DayStats',
      '10': 'daily'
    },
  ],
};

/// Descriptor for `JourneyStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List journeyStatsDescriptor = $convert.base64Decode(
    'CgxKb3VybmV5U3RhdHMSGwoJZGV2aWNlX2lkGAEgASgJUghkZXZpY2VJZBIlCg50b3RhbF9qb3'
    'VybmV5cxgCIAEoBVINdG90YWxKb3VybmV5cxIoChB0b3RhbF9kaXN0YW5jZV9tGAMgASgBUg50'
    'b3RhbERpc3RhbmNlTRIqChF0b3RhbF9kdXJhdGlvbl9tcxgEIAEoA1IPdG90YWxEdXJhdGlvbk'
    '1zEhsKCWF2Z19zcGVlZBgFIAEoAVIIYXZnU3BlZWQSGwoJbWF4X3NwZWVkGAYgASgBUghtYXhT'
    'cGVlZBI3ChhhdmdfZGlzdGFuY2VfcGVyX2pvdXJuZXkYByABKAFSFWF2Z0Rpc3RhbmNlUGVySm'
    '91cm5leRIrCgVkYWlseRgIIAMoCzIVLmxvY2F0aW9uLnYxLkRheVN0YXRzUgVkYWlseQ==');

@$core.Deprecated('Use dayStatsDescriptor instead')
const DayStats$json = {
  '1': 'DayStats',
  '2': [
    {'1': 'date', '3': 1, '4': 1, '5': 9, '10': 'date'},
    {'1': 'journey_count', '3': 2, '4': 1, '5': 5, '10': 'journeyCount'},
    {'1': 'distance_m', '3': 3, '4': 1, '5': 1, '10': 'distanceM'},
    {'1': 'duration_ms', '3': 4, '4': 1, '5': 3, '10': 'durationMs'},
  ],
};

/// Descriptor for `DayStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dayStatsDescriptor = $convert.base64Decode(
    'CghEYXlTdGF0cxISCgRkYXRlGAEgASgJUgRkYXRlEiMKDWpvdXJuZXlfY291bnQYAiABKAVSDG'
    'pvdXJuZXlDb3VudBIdCgpkaXN0YW5jZV9tGAMgASgBUglkaXN0YW5jZU0SHwoLZHVyYXRpb25f'
    'bXMYBCABKANSCmR1cmF0aW9uTXM=');

@$core.Deprecated('Use saveLocationRequestDescriptor instead')
const SaveLocationRequest$json = {
  '1': 'SaveLocationRequest',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'latitude', '3': 3, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 4, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'radius_m', '3': 5, '4': 1, '5': 2, '10': 'radiusM'},
  ],
};

/// Descriptor for `SaveLocationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List saveLocationRequestDescriptor = $convert.base64Decode(
    'ChNTYXZlTG9jYXRpb25SZXF1ZXN0EhsKCWRldmljZV9pZBgBIAEoCVIIZGV2aWNlSWQSEgoEbm'
    'FtZRgCIAEoCVIEbmFtZRIaCghsYXRpdHVkZRgDIAEoAVIIbGF0aXR1ZGUSHAoJbG9uZ2l0dWRl'
    'GAQgASgBUglsb25naXR1ZGUSGQoIcmFkaXVzX20YBSABKAJSB3JhZGl1c00=');

@$core.Deprecated('Use savedLocationDescriptor instead')
const SavedLocation$json = {
  '1': 'SavedLocation',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'device_id', '3': 2, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'latitude', '3': 4, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 5, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'radius_m', '3': 6, '4': 1, '5': 2, '10': 'radiusM'},
    {'1': 'created_at', '3': 7, '4': 1, '5': 3, '10': 'createdAt'},
  ],
};

/// Descriptor for `SavedLocation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List savedLocationDescriptor = $convert.base64Decode(
    'Cg1TYXZlZExvY2F0aW9uEg4KAmlkGAEgASgJUgJpZBIbCglkZXZpY2VfaWQYAiABKAlSCGRldm'
    'ljZUlkEhIKBG5hbWUYAyABKAlSBG5hbWUSGgoIbGF0aXR1ZGUYBCABKAFSCGxhdGl0dWRlEhwK'
    'CWxvbmdpdHVkZRgFIAEoAVIJbG9uZ2l0dWRlEhkKCHJhZGl1c19tGAYgASgCUgdyYWRpdXNNEh'
    '0KCmNyZWF0ZWRfYXQYByABKANSCWNyZWF0ZWRBdA==');

@$core.Deprecated('Use getSavedLocationsRequestDescriptor instead')
const GetSavedLocationsRequest$json = {
  '1': 'GetSavedLocationsRequest',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
  ],
};

/// Descriptor for `GetSavedLocationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSavedLocationsRequestDescriptor =
    $convert.base64Decode(
        'ChhHZXRTYXZlZExvY2F0aW9uc1JlcXVlc3QSGwoJZGV2aWNlX2lkGAEgASgJUghkZXZpY2VJZA'
        '==');

@$core.Deprecated('Use getSavedLocationsResponseDescriptor instead')
const GetSavedLocationsResponse$json = {
  '1': 'GetSavedLocationsResponse',
  '2': [
    {
      '1': 'locations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.location.v1.SavedLocation',
      '10': 'locations'
    },
  ],
};

/// Descriptor for `GetSavedLocationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSavedLocationsResponseDescriptor =
    $convert.base64Decode(
        'ChlHZXRTYXZlZExvY2F0aW9uc1Jlc3BvbnNlEjgKCWxvY2F0aW9ucxgBIAMoCzIaLmxvY2F0aW'
        '9uLnYxLlNhdmVkTG9jYXRpb25SCWxvY2F0aW9ucw==');

@$core.Deprecated('Use deleteSavedLocationRequestDescriptor instead')
const DeleteSavedLocationRequest$json = {
  '1': 'DeleteSavedLocationRequest',
  '2': [
    {'1': 'location_id', '3': 1, '4': 1, '5': 9, '10': 'locationId'},
  ],
};

/// Descriptor for `DeleteSavedLocationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteSavedLocationRequestDescriptor =
    $convert.base64Decode(
        'ChpEZWxldGVTYXZlZExvY2F0aW9uUmVxdWVzdBIfCgtsb2NhdGlvbl9pZBgBIAEoCVIKbG9jYX'
        'Rpb25JZA==');

@$core.Deprecated('Use createShareLinkRequestDescriptor instead')
const CreateShareLinkRequest$json = {
  '1': 'CreateShareLinkRequest',
  '2': [
    {'1': 'journey_id', '3': 1, '4': 1, '5': 9, '10': 'journeyId'},
    {'1': 'duration_hours', '3': 2, '4': 1, '5': 3, '10': 'durationHours'},
  ],
};

/// Descriptor for `CreateShareLinkRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createShareLinkRequestDescriptor =
    $convert.base64Decode(
        'ChZDcmVhdGVTaGFyZUxpbmtSZXF1ZXN0Eh0KCmpvdXJuZXlfaWQYASABKAlSCWpvdXJuZXlJZB'
        'IlCg5kdXJhdGlvbl9ob3VycxgCIAEoA1INZHVyYXRpb25Ib3Vycw==');

@$core.Deprecated('Use shareLinkDescriptor instead')
const ShareLink$json = {
  '1': 'ShareLink',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'journey_id', '3': 2, '4': 1, '5': 9, '10': 'journeyId'},
    {'1': 'url', '3': 3, '4': 1, '5': 9, '10': 'url'},
    {'1': 'expires_at', '3': 4, '4': 1, '5': 3, '10': 'expiresAt'},
    {'1': 'expired', '3': 5, '4': 1, '5': 8, '10': 'expired'},
  ],
};

/// Descriptor for `ShareLink`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List shareLinkDescriptor = $convert.base64Decode(
    'CglTaGFyZUxpbmsSDgoCaWQYASABKAlSAmlkEh0KCmpvdXJuZXlfaWQYAiABKAlSCWpvdXJuZX'
    'lJZBIQCgN1cmwYAyABKAlSA3VybBIdCgpleHBpcmVzX2F0GAQgASgDUglleHBpcmVzQXQSGAoH'
    'ZXhwaXJlZBgFIAEoCFIHZXhwaXJlZA==');

@$core.Deprecated('Use getShareLinkRequestDescriptor instead')
const GetShareLinkRequest$json = {
  '1': 'GetShareLinkRequest',
  '2': [
    {'1': 'share_id', '3': 1, '4': 1, '5': 9, '10': 'shareId'},
  ],
};

/// Descriptor for `GetShareLinkRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getShareLinkRequestDescriptor =
    $convert.base64Decode(
        'ChNHZXRTaGFyZUxpbmtSZXF1ZXN0EhkKCHNoYXJlX2lkGAEgASgJUgdzaGFyZUlk');

@$core.Deprecated('Use exportRequestDescriptor instead')
const ExportRequest$json = {
  '1': 'ExportRequest',
  '2': [
    {'1': 'journey_id', '3': 1, '4': 1, '5': 9, '10': 'journeyId'},
    {'1': 'format', '3': 2, '4': 1, '5': 9, '10': 'format'},
  ],
};

/// Descriptor for `ExportRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportRequestDescriptor = $convert.base64Decode(
    'Cg1FeHBvcnRSZXF1ZXN0Eh0KCmpvdXJuZXlfaWQYASABKAlSCWpvdXJuZXlJZBIWCgZmb3JtYX'
    'QYAiABKAlSBmZvcm1hdA==');

@$core.Deprecated('Use exportResponseDescriptor instead')
const ExportResponse$json = {
  '1': 'ExportResponse',
  '2': [
    {'1': 'filename', '3': 1, '4': 1, '5': 9, '10': 'filename'},
    {'1': 'data', '3': 2, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `ExportResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportResponseDescriptor = $convert.base64Decode(
    'Cg5FeHBvcnRSZXNwb25zZRIaCghmaWxlbmFtZRgBIAEoCVIIZmlsZW5hbWUSEgoEZGF0YRgCIA'
    'EoDFIEZGF0YQ==');

@$core.Deprecated('Use deviceDescriptor instead')
const Device$json = {
  '1': 'Device',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'platform', '3': 3, '4': 1, '5': 9, '10': 'platform'},
    {'1': 'last_seen', '3': 4, '4': 1, '5': 3, '10': 'lastSeen'},
    {'1': 'active', '3': 5, '4': 1, '5': 8, '10': 'active'},
  ],
};

/// Descriptor for `Device`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceDescriptor = $convert.base64Decode(
    'CgZEZXZpY2USDgoCaWQYASABKAlSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSGgoIcGxhdGZvcm'
    '0YAyABKAlSCHBsYXRmb3JtEhsKCWxhc3Rfc2VlbhgEIAEoA1IIbGFzdFNlZW4SFgoGYWN0aXZl'
    'GAUgASgIUgZhY3RpdmU=');

@$core.Deprecated('Use getDevicesRequestDescriptor instead')
const GetDevicesRequest$json = {
  '1': 'GetDevicesRequest',
};

/// Descriptor for `GetDevicesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDevicesRequestDescriptor =
    $convert.base64Decode('ChFHZXREZXZpY2VzUmVxdWVzdA==');

@$core.Deprecated('Use getDevicesResponseDescriptor instead')
const GetDevicesResponse$json = {
  '1': 'GetDevicesResponse',
  '2': [
    {
      '1': 'devices',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.location.v1.Device',
      '10': 'devices'
    },
  ],
};

/// Descriptor for `GetDevicesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDevicesResponseDescriptor = $convert.base64Decode(
    'ChJHZXREZXZpY2VzUmVzcG9uc2USLQoHZGV2aWNlcxgBIAMoCzITLmxvY2F0aW9uLnYxLkRldm'
    'ljZVIHZGV2aWNlcw==');

@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = {
  '1': 'Empty',
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor =
    $convert.base64Decode('CgVFbXB0eQ==');
