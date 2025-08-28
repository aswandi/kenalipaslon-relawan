<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class Volunteer extends Authenticatable
{
    use HasFactory, Notifiable;

    protected $fillable = [
        'ktp_number',
        'full_name',
        'phone_number',
        'password',
        'role',
        'is_active',
    ];

    protected $hidden = [
        'password',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function assignments()
    {
        return $this->hasMany(VolunteerAssignment::class);
    }

    public function fieldRecords()
    {
        return $this->hasMany(FieldRecord::class);
    }

    public function getAuthIdentifierName()
    {
        return 'phone_number';
    }

    public function getAuthPassword()
    {
        return $this->password;
    }
}