<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class FieldRecord extends Model
{
    use HasFactory;

    protected $fillable = [
        'volunteer_id',
        'voter_id',
        'latitude',
        'longitude',
        'responded_at',
        'completion_status',
        'total_questions',
        'answered_questions',
        'photo_path',
        'notes',
        'sync_status',
    ];

    protected $casts = [
        'responded_at' => 'datetime',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
    ];

    public function volunteer()
    {
        return $this->belongsTo(Volunteer::class);
    }

    public function voter()
    {
        return $this->belongsTo(Voter::class);
    }

    public function surveyResponseDetails()
    {
        return $this->hasMany(SurveyResponseDetail::class);
    }

    public function getCompletionPercentageAttribute()
    {
        if ($this->total_questions == 0) return 0;
        return round(($this->answered_questions / $this->total_questions) * 100, 2);
    }

    public function isComplete()
    {
        return $this->completion_status === 'complete';
    }
}