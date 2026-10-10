import '../models/club.dart';
import '../models/club_gallery_request.dart';
import '../models/location.dart';

abstract class ClubRepository {
  Future<String> createClub(Club club);
  Future<Club?> getClub(String id);
  Future<List<Club>> getMyClubs();
  Future<List<LocationCountry>> getLocations();
  Future<void> updateClub(String clubId, Club club);
  Future<void> updateClubFields(String clubId, Map<String, dynamic> fields, {Club? club});
  Future<void> createGallery(String clubId, ClubGalleryRequest request);
}
