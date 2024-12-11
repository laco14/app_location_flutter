import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Clé API Yelp
const String apiKey =
    'g74QAfcY1PFprWzL5HUW7UIDBrlq0xW3v798oK8Q16yxlZxOoVSRv0I4hVOkZ5Lq9RBBapOtQnyWeAlYkcV1eleFMkE8D-dIemJUIifeqp8cqsttMui6P4FUokxQZ3Yx';

// Villes disponibles
const List<String> villes = [
  'Paris',
  'Marseille',
  'Lyon',
  'Toulouse',
  'Nice',
  'Nantes',
  'Montpellier',
  'Strasbourg',
  'Lille'
];

// Options pour le bouton déroulant "Prix" et "Spécialités"
const List<String> prix = ['Prix', '€', '€€', '€€€', '€€€€'];
const List<String> specialite = [
  'Spécialité',
  'pizza',
  'sushi',
  'mexican',
  'italian',
  'french',
  'halal'
];

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String selectedCity = 'Paris'; // Ville par défaut
  String selectedPrix = prix[0]; // Option par défaut
  String selectedSpecialite = specialite[0];
  List<dynamic> businesses = [];
  bool isLoading = true;

  Map<String, dynamic> cityCoordinates = {
    'Paris': {'latitude': 48.8566, 'longitude': 2.3522},
    'Lyon': {'latitude': 45.7640, 'longitude': 4.8357},
    'Marseille': {'latitude': 43.2965, 'longitude': 5.3698},
    'Toulouse': {'latitude': 43.6047, 'longitude': 1.4442},
    'Nice': {'latitude': 43.7102, 'longitude': 7.2620},
    'Nantes': {'latitude': 47.2184, 'longitude': -1.5536},
    'Montpellier': {'latitude': 43.6108, 'longitude': 3.8767},
    'Strasbourg': {'latitude': 48.5734, 'longitude': 7.7521},
    'Lille': {'latitude': 50.6292, 'longitude': 3.0573},
  };

  @override
  void initState() {
    super.initState();
    fetchBusinesses(); // Charger les entreprises au démarrage
  }

  Future<void> fetchBusinesses() async {
    setState(() {
      isLoading = true; // Afficher le loader pendant le rafraîchissement
    });

    String filter = '';

    // Filtrage par prix
    if (selectedPrix != 'Prix') {
      int priceLevel =
          prix.indexOf(selectedPrix); // Convertir en niveau numérique
      filter += '&price=$priceLevel';
    }

    // Filtrage par spécialité
    if (selectedSpecialite != "Spécialité") {
      filter += '&categories=$selectedSpecialite';
    }

    final url = Uri.parse(
        'https://api.yelp.com/v3/businesses/search?location=$selectedCity$filter&limit=10');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> businessesData = data['businesses'];

      // Charger les détails de chaque entreprise
      List<dynamic> businessesWithHours = [];
      for (var business in businessesData) {
        final detailsUrl =
            Uri.parse('https://api.yelp.com/v3/businesses/${business['id']}');
        final detailsResponse = await http.get(
          detailsUrl,
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        );

        if (detailsResponse.statusCode == 200) {
          final details = json.decode(detailsResponse.body);
          business['hours'] = details['hours'] ?? [];
        }

        businessesWithHours.add(business);
      }

      setState(() {
        businesses = businessesWithHours;
        isLoading = false; // Masquer le loader après avoir récupéré les données
      });
    } else {
      setState(() {
        isLoading = false; // Masquer le loader même en cas d'erreur
      });
      throw Exception('Erreur lors de la récupération des données Yelp');
    }
  }

  Widget buildRestaurantList(List<dynamic> businesses) {
    return Expanded(
      flex: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // Ajout de marge
        child: businesses.isNotEmpty
            ? ListView.builder(
                itemCount: businesses.length,
                itemBuilder: (context, index) {
                  final business = businesses[index];
                  String imageUrl = business['image_url'] ??
                      'https://via.placeholder.com/150';
                  String rating = business['rating']?.toString() ?? 'N/A';
                  List<dynamic> hours = business['hours'].isNotEmpty
                      ? business['hours'][0]['open']
                      : [];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image du restaurant
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              imageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16), // Espacement
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  business['name'],
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                    "Catégories: ${business['categories'][0]['title']}"),
                                Text(
                                    "Adresse: ${business['location']['address1']}, ${business['location']['city']}"),
                                Text("Téléphone: ${business['phone']}"),
                                Text("Note: $rating étoiles"),
                                Text(
                                    "Prix: ${business['price'] ?? 'Non disponible'}"),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Horaires d'ouverture
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: hours.isNotEmpty
                                  ? hours.map((day) {
                                      List<String> daysOfWeek = [
                                        "Lundi",
                                        "Mardi",
                                        "Mercredi",
                                        "Jeudi",
                                        "Vendredi",
                                        "Samedi",
                                        "Dimanche"
                                      ];
                                      String dayName = daysOfWeek[day['day']];
                                      String openTime =
                                          '${day['start'].substring(0, 2)}:${day['start'].substring(2, 4)}';
                                      String closeTime =
                                          '${day['end'].substring(0, 2)}:${day['end'].substring(2, 4)}';
                                      return Text(
                                        "$dayName : $openTime - $closeTime",
                                        style: const TextStyle(fontSize: 14),
                                      );
                                    }).toList()
                                  : [
                                      const Text("Horaires non disponibles",
                                          style: TextStyle(fontSize: 14))
                                    ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : Center(child: Text("Aucun restaurant trouvé")),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 170, // Augmenté de 20 unités
        backgroundColor: Color.fromARGB(255, 202, 230, 235),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/assets/images/DîneViewLOGO.png',
                height: 0, width: 150, fit: BoxFit.contain),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedCity,
                items: villes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 18)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCity = value;
                      fetchBusinesses();
                    });
                  }
                },
                underline: const SizedBox(),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedPrix,
                items: prix.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 18)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedPrix = value;
                      fetchBusinesses();
                    });
                  }
                },
                underline: const SizedBox(),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedSpecialite,
                items: specialite.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 18)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedSpecialite = value;
                      fetchBusinesses();
                    });
                  }
                },
                underline: const SizedBox(),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // Espace global
        child: Row(
          children: [
            isLoading
                ? Expanded(child: Center(child: CircularProgressIndicator()))
                : buildRestaurantList(businesses),
            isLoading
                ? Expanded(child: Center(child: CircularProgressIndicator()))
                : Expanded(
                    flex: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15), // Arrondi
                        color: Colors.transparent,
                      ),
                      child: MapScreen(
                        initialLatitude: cityCoordinates[selectedCity]
                            ['latitude'],
                        initialLongitude: cityCoordinates[selectedCity]
                            ['longitude'],
                        businesses: businesses,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
