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
            $table->text('maps_link')->nullable()->change();
            $table->text('website')->nullable()->change();
            $table->text('business_name')->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('leads', function (Blueprint $table) {
            $table->string('maps_link')->nullable()->change();
            $table->string('website')->nullable()->change();
            $table->string('business_name')->change();
        });
    }
};
