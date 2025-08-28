<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class VolunteerAssignment extends Model
{
    use HasFactory;

    protected $fillable = [
        'volunteer_id',
        'administrative_area_id',
        'district',
        'village',
        'rw',
        'rt',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function volunteer()
    {
        return $this->belongsTo(Volunteer::class);
    }

    public function administrativeArea()
    {
        return $this->belongsTo(AdministrativeArea::class);
    }
}