<?php
// public/test_fix.php
require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';

use App\Models\User;

header('Content-Type: application/json');

try {
    $user = new User();
    $traits = class_uses($user);
    $hasSanctum = in_array('Laravel\Sanctum\HasApiTokens', $traits);
    $hasOtpStatus = in_array('otp_status', $user->getFillable());
    
    echo json_encode([
        'status' => 'success',
        'has_sanctum_trait' => $hasSanctum,
        'has_otp_status_field' => $hasOtpStatus,
        'message' => ($hasSanctum && $hasOtpStatus) ? 'Fix is ACTIVE' : 'Fix is PARTIAL or MISSING'
    ]);
} catch (\Exception $e) {
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
}
