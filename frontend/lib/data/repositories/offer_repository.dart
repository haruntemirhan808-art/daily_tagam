import '../../core/network/api_client.dart';

class OfferRepository {
  final ApiClient apiClient;

  OfferRepository(this.apiClient);

  /// Fetches all active food offers from the backend feed
  Future<List<dynamic>> fetchActiveOffers() async {
    try {
      final response = await apiClient.dio.get('/offers');
      if (response.statusCode == 200 && response.data != null) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Submits an order reservation for a chosen package
  Future<bool> reserveOffer(int foodOfferId, int quantity) async {
    try {
      final response = await apiClient.dio.post(
        '/offers/reserve',
        data: {
          'food_offer_id': foodOfferId,
          'quantity': quantity,
        },
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}