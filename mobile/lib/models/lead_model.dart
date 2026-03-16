class Lead {
  final int? id;
  final String businessName;
  final String? ownerName;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? website;
  final String? instagram;
  final String? facebook;
  final String? mapsLink;
  final String? address;
  final String? city;
  final String? category;
  final String status;
  final String? aiPitch;
  final String? linkedin;
  final String? twitter;
  final String? youtube;
  final String? rating;
  final String? reviewsCount;
  final String? openingHours;
  final DateTime? createdAt;
  bool isSavedLocally;
  bool isViewed;

  Lead({
    this.id,
    required this.businessName,
    this.ownerName,
    this.phone,
    this.whatsapp,
    this.email,
    this.website,
    this.instagram,
    this.facebook,
    this.mapsLink,
    this.address,
    this.city,
    this.category,
    this.status = 'New',
    this.aiPitch,
    this.linkedin,
    this.twitter,
    this.youtube,
    this.rating,
    this.reviewsCount,
    this.openingHours,
    this.createdAt,
    this.isSavedLocally = false,
    this.isViewed = false,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'],
      businessName: json['business_name'] ?? '',
      ownerName: json['owner_name'],
      phone: json['phone'],
      whatsapp: json['whatsapp'],
      email: json['email'],
      website: json['website'],
      instagram: json['instagram'],
      facebook: json['facebook'],
      mapsLink: json['maps_link'],
      address: json['address'],
      city: json['city'],
      category: json['category'],
      status: json['status'] ?? 'New',
      aiPitch: json['ai_pitch'],
      linkedin: json['linkedin'],
      twitter: json['twitter'],
      youtube: json['youtube'],
      rating: json['rating'],
      reviewsCount: json['reviews_count'],
      openingHours: json['opening_hours'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'owner_name': ownerName,
      'phone': phone,
      'whatsapp': whatsapp,
      'email': email,
      'website': website,
      'instagram': instagram,
      'facebook': facebook,
      'maps_link': mapsLink,
      'address': address,
      'city': city,
      'category': category,
      'status': status,
      'ai_pitch': aiPitch,
      'linkedin': linkedin,
      'twitter': twitter,
      'youtube': youtube,
      'rating': rating,
      'reviews_count': reviewsCount,
      'opening_hours': openingHours,
    };
  }
}
