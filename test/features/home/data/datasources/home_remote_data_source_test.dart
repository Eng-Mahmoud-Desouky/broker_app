// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import 'package:broker_app/core/error/exceptions.dart';
// import 'package:broker_app/features/home/data/datasources/home_remote_data_source_impl.dart';
// import 'package:broker_app/features/home/data/models/offer_model.dart';

// import 'home_remote_data_source_test.mocks.dart';

// @GenerateMocks([SupabaseClient, SupabaseQueryBuilder])
// void main() {
//   late HomeRemoteDataSourceImpl dataSource;
//   late MockSupabaseClient mockSupabaseClient;
//   late MockSupabaseQueryBuilder mockQueryBuilder;

//   setUp(() {
//     mockSupabaseClient = MockSupabaseClient();
//     mockQueryBuilder = MockSupabaseQueryBuilder();
//     dataSource = HomeRemoteDataSourceImpl(supabaseClient: mockSupabaseClient);
//   });

//   group('getOffers', () {
//     final tOfferData = [
//       {
//         'id': '1',
//         'title': 'Test Offer 1',
//         'description': 'Test Description 1',
//         'image_url': 'https://example.com/image1.jpg',
//         'discount_percentage': '50%',
//         'valid_until': '2024-12-31T23:59:59.000Z',
//         'action_url': '/offers/1',
//         'is_active': true,
//       },
//       {
//         'id': '2',
//         'title': 'Test Offer 2',
//         'description': 'Test Description 2',
//         'image_url': 'https://example.com/image2.jpg',
//         'discount_percentage': null,
//         'valid_until': '2024-12-31T23:59:59.000Z',
//         'action_url': '/offers/2',
//         'is_active': true,
//       },
//     ];

//     test('should return list of OfferModel when call is successful', () async {
//       // arrange
//       when(mockSupabaseClient.from('offers')).thenReturn(mockQueryBuilder);
//       when(mockQueryBuilder.select('*')).thenReturn(mockQueryBuilder);
//       when(mockQueryBuilder.eq('is_active', true)).thenReturn(mockQueryBuilder);
//       when(mockQueryBuilder.gte('valid_until', any)).thenReturn(mockQueryBuilder);
//       when(mockQueryBuilder.order('created_at', ascending: false))
//           .thenAnswer((_) async => tOfferData);

//       // act
//       final result = await dataSource.getOffers();

//       // assert
//       expect(result, isA<List<OfferModel>>());
//       expect(result.length, 2);
//       expect(result[0].id, '1');
//       expect(result[0].title, 'Test Offer 1');
//       expect(result[0].discountPercentage, '50%');
//       expect(result[1].id, '2');
//       expect(result[1].discountPercentage, null);
//     });

//     test('should throw ServerException when Supabase throws PostgrestException', () async {
//       // arrange
//       when(mockSupabaseClient.from('offers')).thenReturn(mockQueryBuilder);
//       when(mockQueryBuilder.select('*')).thenReturn(mockQueryBuilder);
//       when(mockQueryBuilder.eq('is_active', true)).thenReturn(mockQueryBuilder);
//       when(mockQueryBuilder.gte('valid_until', any)).thenReturn(mockQueryBuilder);
//       when(mockQueryBuilder.order('created_at', ascending: false))
//           .thenThrow(const PostgrestException(message: 'Database error'));

//       // act
//       final call = dataSource.getOffers;

//       // assert
//       expect(() => call(), throwsA(isA<ServerException>()));
//     });

//     test('should throw ServerException when unexpected error occurs', () async {
//       // arrange
//       when(mockSupabaseClient.from('offers')).thenReturn(mockQueryBuilder);
//       when(mockQueryBuilder.select('*')).thenReturn(mockQueryBuilder);
//       when(mockQueryBuilder.eq('is_active', true)).thenReturn(mockQueryBuilder);
//       when(mockQueryBuilder.gte('valid_until', any)).thenReturn(mockQueryBuilder);
//       when(mockQueryBuilder.order('created_at', ascending: false))
//           .thenThrow(Exception('Unexpected error'));

//       // act
//       final call = dataSource.getOffers;

//       // assert
//       expect(() => call(), throwsA(isA<ServerException>()));
//     });
//   });
// }
