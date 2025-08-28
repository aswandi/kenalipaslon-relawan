<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AdministrativeArea extends Model
{
    use HasFactory;

    protected $fillable = [
        'code',
        'name',
        'type',
        'parent_id',
        'postal_code',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function parent()
    {
        return $this->belongsTo(AdministrativeArea::class, 'parent_id');
    }

    public function children()
    {
        return $this->hasMany(AdministrativeArea::class, 'parent_id');
    }

    public function voters()
    {
        return $this->hasMany(Voter::class, 'village_id');
    }

    public function volunteerAssignments()
    {
        return $this->hasMany(VolunteerAssignment::class);
    }
}