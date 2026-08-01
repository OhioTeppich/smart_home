import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/parcel_tracking/domain/entities/parcel_status.dart';
import 'package:smart_home/features/parcel_tracking/infrastructure/models/track17_status_dto.dart';

void main() {
  group('Track17StatusDto', () {
    test('parses number and latest_status from track_info', () {
      final dto = Track17StatusDto.fromJson({
        'number': '123456789012',
        'track_info': {
          'latest_status': {'status': 'InTransit', 'sub_status': 'InTransit_Other'},
        },
      });

      expect(dto.trackingNumber, '123456789012');
      expect(dto.status, 'InTransit');
      expect(dto.subStatus, 'InTransit_Other');
    });

    test('defaults to NotFound when track_info is missing', () {
      final dto = Track17StatusDto.fromJson({'number': '123456789012'});

      expect(dto.status, 'NotFound');
      expect(dto.subStatus, isNull);
      expect(dto.estimatedDelivery, isNull);
    });

    test('parses estimated_delivery_date, preferring the "to" bound', () {
      final dto = Track17StatusDto.fromJson({
        'number': '123456789012',
        'track_info': {
          'latest_status': {'status': 'InTransit'},
          'time_metrics': {
            'estimated_delivery_date': {
              'source': 'Official',
              'from': '2026-08-01T08:00:00+02:00',
              'to': '2026-08-03T18:00:00+02:00',
            },
          },
        },
      });

      expect(dto.estimatedDelivery, DateTime.parse('2026-08-03T18:00:00+02:00'));
    });

    test('falls back to "from" when "to" is missing', () {
      final dto = Track17StatusDto.fromJson({
        'number': '123456789012',
        'track_info': {
          'latest_status': {'status': 'InTransit'},
          'time_metrics': {
            'estimated_delivery_date': {'from': '2026-08-01T08:00:00+02:00'},
          },
        },
      });

      expect(dto.estimatedDelivery, DateTime.parse('2026-08-01T08:00:00+02:00'));
    });

    test('is null when time_metrics has no estimate yet', () {
      final dto = Track17StatusDto.fromJson({
        'number': '123456789012',
        'track_info': {
          'latest_status': {'status': 'InfoReceived'},
        },
      });

      expect(dto.estimatedDelivery, isNull);
    });

    test('maps 17Track statuses to ParcelStatus', () {
      ParcelStatus statusFor(String status) =>
          Track17StatusDto(trackingNumber: 'x', status: status).toParcelStatus();

      expect(statusFor('InTransit'), ParcelStatus.inTransit);
      expect(statusFor('OutForDelivery'), ParcelStatus.outForDelivery);
      expect(statusFor('AvailableForPickup'), ParcelStatus.outForDelivery);
      expect(statusFor('Delivered'), ParcelStatus.delivered);
      expect(statusFor('Expired'), ParcelStatus.exception);
      expect(statusFor('DeliveryFailure'), ParcelStatus.exception);
      expect(statusFor('Exception'), ParcelStatus.exception);
      expect(statusFor('NotFound'), ParcelStatus.unknown);
      expect(statusFor('InfoReceived'), ParcelStatus.unknown);
    });
  });
}
