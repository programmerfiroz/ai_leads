<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Lead extends Model
{
    const STATUS_NEW = 'New';
    const STATUS_CONTACTED = 'Contacted';
    const STATUS_INTERESTED = 'Interested';
    const STATUS_NOT_INTERESTED = 'Not Interested';
    const STATUS_CONVERTED = 'Converted';

    protected $fillable = [
        'business_name',
        'owner_name',
        'phone',
        'whatsapp',
        'email',
        'website',
        'instagram',
        'facebook',
        'maps_link',
        'address',
        'city',
        'category',
        'rating',
        'reviews_count',
        'opening_hours',
        'status',
        'ai_pitch',
        'linkedin',
        'twitter',
        'youtube',
        'user_id',
    ];

    public function history()
    {
        return $this->hasMany(LeadStatusHistory::class);
    }
}
