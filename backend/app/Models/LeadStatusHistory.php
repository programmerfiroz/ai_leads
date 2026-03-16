<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LeadStatusHistory extends Model
{
    protected $table = 'lead_status_history';

    protected $fillable = [
        'lead_id',
        'status',
        'notes',
    ];

    public function lead()
    {
        return $this->belongsTo(Lead::class);
    }
}
