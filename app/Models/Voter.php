<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class Voter extends Model
{
    use HasFactory;

    protected $fillable = [
        'district_id',
        'village_id',
        'district',
        'village',
        'nkk',
        'nik',
        'name',
        'place_of_birth',
        'date_of_birth',
        'marital_status',
        'gender',
        'address',
        'rt',
        'rw',
        'disability',
        'ektp_status',
        'tps',
    ];

    protected $casts = [
        'date_of_birth' => 'date',
    ];

    public function districtArea()
    {
        return $this->belongsTo(AdministrativeArea::class, 'district_id');
    }

    public function villageArea()
    {
        return $this->belongsTo(AdministrativeArea::class, 'village_id');
    }

    public function fieldRecords()
    {
        return $this->hasMany(FieldRecord::class);
    }

    public function getAgeAttribute()
    {
        return $this->date_of_birth->age;
    }

    public function hasBeenSurveyed()
    {
        return $this->fieldRecords()->exists();
    }
}