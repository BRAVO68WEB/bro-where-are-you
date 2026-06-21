// This is a generated file - do not edit.
//
// Generated from location/v1/location.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'location.pb.dart' as $0;

export 'location.pb.dart';

@$pb.GrpcServiceName('location.v1.LocationService')
class LocationServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  LocationServiceClient(super.channel, {super.options, super.interceptors});

  /// Location streaming
  $grpc.ResponseFuture<$0.LocationAck> streamLocations(
    $async.Stream<$0.LocationUpdate> request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$streamLocations, request, options: options)
        .single;
  }

  /// Journey lifecycle
  $grpc.ResponseFuture<$0.Journey> startJourney(
    $0.StartJourneyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$startJourney, request, options: options);
  }

  $grpc.ResponseFuture<$0.Journey> endJourney(
    $0.EndJourneyRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$endJourney, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetJourneysResponse> getJourneys(
    $0.GetJourneysRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getJourneys, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetJourneyPointsResponse> getJourneyPoints(
    $0.GetJourneyPointsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getJourneyPoints, request, options: options);
  }

  /// Auth — Device Code flow
  $grpc.ResponseFuture<$0.DeviceCodeResponse> requestDeviceCode(
    $0.DeviceCodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$requestDeviceCode, request, options: options);
  }

  $grpc.ResponseFuture<$0.DeviceActivationResponse> pollDeviceActivation(
    $0.PollActivationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$pollDeviceActivation, request, options: options);
  }

  /// Journey stats
  $grpc.ResponseFuture<$0.JourneyStats> getJourneyStats(
    $0.GetJourneyStatsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getJourneyStats, request, options: options);
  }

  /// Saved Locations
  $grpc.ResponseFuture<$0.SavedLocation> saveLocation(
    $0.SaveLocationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$saveLocation, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetSavedLocationsResponse> getSavedLocations(
    $0.GetSavedLocationsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getSavedLocations, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> deleteSavedLocation(
    $0.DeleteSavedLocationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteSavedLocation, request, options: options);
  }

  /// Share Links
  $grpc.ResponseFuture<$0.ShareLink> createShareLink(
    $0.CreateShareLinkRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createShareLink, request, options: options);
  }

  $grpc.ResponseFuture<$0.ShareLink> getShareLink(
    $0.GetShareLinkRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getShareLink, request, options: options);
  }

  /// Export
  $grpc.ResponseFuture<$0.ExportResponse> exportJourney(
    $0.ExportRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$exportJourney, request, options: options);
  }

  /// Devices
  $grpc.ResponseFuture<$0.GetDevicesResponse> getDevices(
    $0.GetDevicesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDevices, request, options: options);
  }

  // method descriptors

  static final _$streamLocations =
      $grpc.ClientMethod<$0.LocationUpdate, $0.LocationAck>(
          '/location.v1.LocationService/StreamLocations',
          ($0.LocationUpdate value) => value.writeToBuffer(),
          $0.LocationAck.fromBuffer);
  static final _$startJourney =
      $grpc.ClientMethod<$0.StartJourneyRequest, $0.Journey>(
          '/location.v1.LocationService/StartJourney',
          ($0.StartJourneyRequest value) => value.writeToBuffer(),
          $0.Journey.fromBuffer);
  static final _$endJourney =
      $grpc.ClientMethod<$0.EndJourneyRequest, $0.Journey>(
          '/location.v1.LocationService/EndJourney',
          ($0.EndJourneyRequest value) => value.writeToBuffer(),
          $0.Journey.fromBuffer);
  static final _$getJourneys =
      $grpc.ClientMethod<$0.GetJourneysRequest, $0.GetJourneysResponse>(
          '/location.v1.LocationService/GetJourneys',
          ($0.GetJourneysRequest value) => value.writeToBuffer(),
          $0.GetJourneysResponse.fromBuffer);
  static final _$getJourneyPoints = $grpc.ClientMethod<
          $0.GetJourneyPointsRequest, $0.GetJourneyPointsResponse>(
      '/location.v1.LocationService/GetJourneyPoints',
      ($0.GetJourneyPointsRequest value) => value.writeToBuffer(),
      $0.GetJourneyPointsResponse.fromBuffer);
  static final _$requestDeviceCode =
      $grpc.ClientMethod<$0.DeviceCodeRequest, $0.DeviceCodeResponse>(
          '/location.v1.LocationService/RequestDeviceCode',
          ($0.DeviceCodeRequest value) => value.writeToBuffer(),
          $0.DeviceCodeResponse.fromBuffer);
  static final _$pollDeviceActivation =
      $grpc.ClientMethod<$0.PollActivationRequest, $0.DeviceActivationResponse>(
          '/location.v1.LocationService/PollDeviceActivation',
          ($0.PollActivationRequest value) => value.writeToBuffer(),
          $0.DeviceActivationResponse.fromBuffer);
  static final _$getJourneyStats =
      $grpc.ClientMethod<$0.GetJourneyStatsRequest, $0.JourneyStats>(
          '/location.v1.LocationService/GetJourneyStats',
          ($0.GetJourneyStatsRequest value) => value.writeToBuffer(),
          $0.JourneyStats.fromBuffer);
  static final _$saveLocation =
      $grpc.ClientMethod<$0.SaveLocationRequest, $0.SavedLocation>(
          '/location.v1.LocationService/SaveLocation',
          ($0.SaveLocationRequest value) => value.writeToBuffer(),
          $0.SavedLocation.fromBuffer);
  static final _$getSavedLocations = $grpc.ClientMethod<
          $0.GetSavedLocationsRequest, $0.GetSavedLocationsResponse>(
      '/location.v1.LocationService/GetSavedLocations',
      ($0.GetSavedLocationsRequest value) => value.writeToBuffer(),
      $0.GetSavedLocationsResponse.fromBuffer);
  static final _$deleteSavedLocation =
      $grpc.ClientMethod<$0.DeleteSavedLocationRequest, $0.Empty>(
          '/location.v1.LocationService/DeleteSavedLocation',
          ($0.DeleteSavedLocationRequest value) => value.writeToBuffer(),
          $0.Empty.fromBuffer);
  static final _$createShareLink =
      $grpc.ClientMethod<$0.CreateShareLinkRequest, $0.ShareLink>(
          '/location.v1.LocationService/CreateShareLink',
          ($0.CreateShareLinkRequest value) => value.writeToBuffer(),
          $0.ShareLink.fromBuffer);
  static final _$getShareLink =
      $grpc.ClientMethod<$0.GetShareLinkRequest, $0.ShareLink>(
          '/location.v1.LocationService/GetShareLink',
          ($0.GetShareLinkRequest value) => value.writeToBuffer(),
          $0.ShareLink.fromBuffer);
  static final _$exportJourney =
      $grpc.ClientMethod<$0.ExportRequest, $0.ExportResponse>(
          '/location.v1.LocationService/ExportJourney',
          ($0.ExportRequest value) => value.writeToBuffer(),
          $0.ExportResponse.fromBuffer);
  static final _$getDevices =
      $grpc.ClientMethod<$0.GetDevicesRequest, $0.GetDevicesResponse>(
          '/location.v1.LocationService/GetDevices',
          ($0.GetDevicesRequest value) => value.writeToBuffer(),
          $0.GetDevicesResponse.fromBuffer);
}

@$pb.GrpcServiceName('location.v1.LocationService')
abstract class LocationServiceBase extends $grpc.Service {
  $core.String get $name => 'location.v1.LocationService';

  LocationServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.LocationUpdate, $0.LocationAck>(
        'StreamLocations',
        streamLocations,
        true,
        false,
        ($core.List<$core.int> value) => $0.LocationUpdate.fromBuffer(value),
        ($0.LocationAck value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StartJourneyRequest, $0.Journey>(
        'StartJourney',
        startJourney_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.StartJourneyRequest.fromBuffer(value),
        ($0.Journey value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EndJourneyRequest, $0.Journey>(
        'EndJourney',
        endJourney_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.EndJourneyRequest.fromBuffer(value),
        ($0.Journey value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetJourneysRequest, $0.GetJourneysResponse>(
            'GetJourneys',
            getJourneys_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetJourneysRequest.fromBuffer(value),
            ($0.GetJourneysResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetJourneyPointsRequest,
            $0.GetJourneyPointsResponse>(
        'GetJourneyPoints',
        getJourneyPoints_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetJourneyPointsRequest.fromBuffer(value),
        ($0.GetJourneyPointsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeviceCodeRequest, $0.DeviceCodeResponse>(
        'RequestDeviceCode',
        requestDeviceCode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeviceCodeRequest.fromBuffer(value),
        ($0.DeviceCodeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PollActivationRequest,
            $0.DeviceActivationResponse>(
        'PollDeviceActivation',
        pollDeviceActivation_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.PollActivationRequest.fromBuffer(value),
        ($0.DeviceActivationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetJourneyStatsRequest, $0.JourneyStats>(
        'GetJourneyStats',
        getJourneyStats_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetJourneyStatsRequest.fromBuffer(value),
        ($0.JourneyStats value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SaveLocationRequest, $0.SavedLocation>(
        'SaveLocation',
        saveLocation_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SaveLocationRequest.fromBuffer(value),
        ($0.SavedLocation value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetSavedLocationsRequest,
            $0.GetSavedLocationsResponse>(
        'GetSavedLocations',
        getSavedLocations_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetSavedLocationsRequest.fromBuffer(value),
        ($0.GetSavedLocationsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteSavedLocationRequest, $0.Empty>(
        'DeleteSavedLocation',
        deleteSavedLocation_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DeleteSavedLocationRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateShareLinkRequest, $0.ShareLink>(
        'CreateShareLink',
        createShareLink_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.CreateShareLinkRequest.fromBuffer(value),
        ($0.ShareLink value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetShareLinkRequest, $0.ShareLink>(
        'GetShareLink',
        getShareLink_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetShareLinkRequest.fromBuffer(value),
        ($0.ShareLink value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ExportRequest, $0.ExportResponse>(
        'ExportJourney',
        exportJourney_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ExportRequest.fromBuffer(value),
        ($0.ExportResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetDevicesRequest, $0.GetDevicesResponse>(
        'GetDevices',
        getDevices_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetDevicesRequest.fromBuffer(value),
        ($0.GetDevicesResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.LocationAck> streamLocations(
      $grpc.ServiceCall call, $async.Stream<$0.LocationUpdate> request);

  $async.Future<$0.Journey> startJourney_Pre($grpc.ServiceCall $call,
      $async.Future<$0.StartJourneyRequest> $request) async {
    return startJourney($call, await $request);
  }

  $async.Future<$0.Journey> startJourney(
      $grpc.ServiceCall call, $0.StartJourneyRequest request);

  $async.Future<$0.Journey> endJourney_Pre($grpc.ServiceCall $call,
      $async.Future<$0.EndJourneyRequest> $request) async {
    return endJourney($call, await $request);
  }

  $async.Future<$0.Journey> endJourney(
      $grpc.ServiceCall call, $0.EndJourneyRequest request);

  $async.Future<$0.GetJourneysResponse> getJourneys_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetJourneysRequest> $request) async {
    return getJourneys($call, await $request);
  }

  $async.Future<$0.GetJourneysResponse> getJourneys(
      $grpc.ServiceCall call, $0.GetJourneysRequest request);

  $async.Future<$0.GetJourneyPointsResponse> getJourneyPoints_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetJourneyPointsRequest> $request) async {
    return getJourneyPoints($call, await $request);
  }

  $async.Future<$0.GetJourneyPointsResponse> getJourneyPoints(
      $grpc.ServiceCall call, $0.GetJourneyPointsRequest request);

  $async.Future<$0.DeviceCodeResponse> requestDeviceCode_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.DeviceCodeRequest> $request) async {
    return requestDeviceCode($call, await $request);
  }

  $async.Future<$0.DeviceCodeResponse> requestDeviceCode(
      $grpc.ServiceCall call, $0.DeviceCodeRequest request);

  $async.Future<$0.DeviceActivationResponse> pollDeviceActivation_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.PollActivationRequest> $request) async {
    return pollDeviceActivation($call, await $request);
  }

  $async.Future<$0.DeviceActivationResponse> pollDeviceActivation(
      $grpc.ServiceCall call, $0.PollActivationRequest request);

  $async.Future<$0.JourneyStats> getJourneyStats_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetJourneyStatsRequest> $request) async {
    return getJourneyStats($call, await $request);
  }

  $async.Future<$0.JourneyStats> getJourneyStats(
      $grpc.ServiceCall call, $0.GetJourneyStatsRequest request);

  $async.Future<$0.SavedLocation> saveLocation_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SaveLocationRequest> $request) async {
    return saveLocation($call, await $request);
  }

  $async.Future<$0.SavedLocation> saveLocation(
      $grpc.ServiceCall call, $0.SaveLocationRequest request);

  $async.Future<$0.GetSavedLocationsResponse> getSavedLocations_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetSavedLocationsRequest> $request) async {
    return getSavedLocations($call, await $request);
  }

  $async.Future<$0.GetSavedLocationsResponse> getSavedLocations(
      $grpc.ServiceCall call, $0.GetSavedLocationsRequest request);

  $async.Future<$0.Empty> deleteSavedLocation_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DeleteSavedLocationRequest> $request) async {
    return deleteSavedLocation($call, await $request);
  }

  $async.Future<$0.Empty> deleteSavedLocation(
      $grpc.ServiceCall call, $0.DeleteSavedLocationRequest request);

  $async.Future<$0.ShareLink> createShareLink_Pre($grpc.ServiceCall $call,
      $async.Future<$0.CreateShareLinkRequest> $request) async {
    return createShareLink($call, await $request);
  }

  $async.Future<$0.ShareLink> createShareLink(
      $grpc.ServiceCall call, $0.CreateShareLinkRequest request);

  $async.Future<$0.ShareLink> getShareLink_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetShareLinkRequest> $request) async {
    return getShareLink($call, await $request);
  }

  $async.Future<$0.ShareLink> getShareLink(
      $grpc.ServiceCall call, $0.GetShareLinkRequest request);

  $async.Future<$0.ExportResponse> exportJourney_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ExportRequest> $request) async {
    return exportJourney($call, await $request);
  }

  $async.Future<$0.ExportResponse> exportJourney(
      $grpc.ServiceCall call, $0.ExportRequest request);

  $async.Future<$0.GetDevicesResponse> getDevices_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetDevicesRequest> $request) async {
    return getDevices($call, await $request);
  }

  $async.Future<$0.GetDevicesResponse> getDevices(
      $grpc.ServiceCall call, $0.GetDevicesRequest request);
}
