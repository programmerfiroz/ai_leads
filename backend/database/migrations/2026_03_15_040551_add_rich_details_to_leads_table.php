<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('leads', function (Blueprint $table) {
            $table->string('rating')->nullable()->after('category');
            $table->string('reviews_count')->nullable()->after('rating');
            $table->string('opening_hours')->nullable()->after('reviews_count');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('leads', function (Blueprint $table) {
            $table->dropColumn(['rating', 'reviews_count', 'opening_hours']);
        });
    }
};
