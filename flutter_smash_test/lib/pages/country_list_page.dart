import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smash_test/pages/city_list_page.dart';

class CountryListPage extends StatelessWidget {
  const CountryListPage({super.key});

  Future<QuerySnapshot> _fetchCountries(Source source) {
    return FirebaseFirestore.instance
        .collection('countries')
        .get(GetOptions(source: source));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countries'),
        centerTitle: true,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _fetchCountries(Source.cache),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return FutureBuilder<QuerySnapshot>(
              future: _fetchCountries(Source.server),
              builder: (context, networkSnapshot) {
                if (networkSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!networkSnapshot.hasData ||
                    networkSnapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No countries available.'));
                }

                final countries = networkSnapshot.data!.docs;
                return _buildCountryList(countries, context);
              },
            );
          }

          final countries = snapshot.data!.docs;
          return _buildCountryList(countries, context);
        },
      ),
    );
  }

  Widget _buildCountryList(
      List<QueryDocumentSnapshot> countries, BuildContext context) {
    return ListView.builder(
      itemCount: countries.length,
      itemBuilder: (context, index) {
        final country = countries[index];
        String countryName = country['name'] ?? country.id;

        return ListTile(
          title: Text(
            countryName,
            style: const TextStyle(fontSize: 18.0),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CityListPage(country.id),
              ),
            );
          },
        );
      },
    );
  }
}
