<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AnswerOption extends Model
{
    use HasFactory;

    protected $fillable = [
        'question_id',
        'option_text',
        'option_value',
        'order_number',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function question()
    {
        return $this->belongsTo(Question::class);
    }

    public function surveyResponseDetails()
    {
        return $this->hasMany(SurveyResponseDetail::class);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}