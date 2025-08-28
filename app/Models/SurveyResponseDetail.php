<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SurveyResponseDetail extends Model
{
    use HasFactory;

    protected $fillable = [
        'field_record_id',
        'question_id',
        'answer_option_id',
        'text_answer',
        'numeric_value',
        'weight',
    ];

    protected $casts = [
        'weight' => 'decimal:2',
    ];

    public function fieldRecord()
    {
        return $this->belongsTo(FieldRecord::class);
    }

    public function question()
    {
        return $this->belongsTo(Question::class);
    }

    public function answerOption()
    {
        return $this->belongsTo(AnswerOption::class);
    }
}