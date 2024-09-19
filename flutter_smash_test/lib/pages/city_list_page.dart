import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CityListPage extends StatelessWidget {
  final String countryId;

  const CityListPage(this.countryId, {super.key});

  Future<QuerySnapshot> _fetchCities(Source source) {
    return FirebaseFirestore.instance
        .collection('countries')
        .doc(countryId)
        .collection('cities')
        .get(GetOptions(source: source));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cities in $countryId'),
        centerTitle: true,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _fetchCities(Source.cache),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return FutureBuilder<QuerySnapshot>(
              future: _fetchCities(Source.server),
              builder: (context, networkSnapshot) {
                if (networkSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!networkSnapshot.hasData ||
                    networkSnapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No cities available.'));
                }

                final cities = networkSnapshot.data!.docs;
                return _buildCityList(cities);
              },
            );
          }

          final cities = snapshot.data!.docs;
          return _buildCityList(cities);
        },
      ),
    );
  }

  Widget _buildCityList(List<QueryDocumentSnapshot> cities) {
    return ListView.builder(
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        String cityName = city['name'] ?? 'Unknown city';
        String subcountry = city['subcountry'] ?? 'Unknown subcountry';
        return ListTile(
          title: Text(
            cityName,
            style: const TextStyle(fontSize: 18.0),
          ),
          subtitle: Text(
            subcountry,
            style: const TextStyle(fontSize: 14.0, color: Colors.grey),
          ),
        );
      },
    );
  }
}
