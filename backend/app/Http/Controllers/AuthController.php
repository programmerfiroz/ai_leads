<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'email' => 'required|email',
            'phone' => 'required|string',
            'organization_name' => 'required|string',
            'business_category' => 'required|string',
        ]);

        // Check if user already exists
        $user = User::where('phone', $request->phone)
                    ->orWhere('email', $request->email)
                    ->first();

        if ($user) {
            // If user exists but is trying to register again
            $user->update([
                'name' => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,
                'organization_name' => $request->organization_name,
                'business_category' => $request->business_category,
                'otp_status' => true,
            ]);
        } else {
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,
                'organization_name' => $request->organization_name,
                'business_category' => $request->business_category,
                'password' => Hash::make('password'),
                'otp_status' => true,
            ]);
        }

        try {
            $token = $user->createToken('auth_token')->plainTextToken;
            return response()->json([
                'access_token' => $token,
                'token_type' => 'Bearer',
                'user' => $user
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'User saved, but token generation failed. Please ensuring "HasApiTokens" is in User model.',
                'error' => $e->getMessage(),
                'user' => $user
            ], 500);
        }
    }

    public function login(Request $request)
    {
        $request->validate([
            'phone' => 'required|string',
            'otp' => 'required|string',
        ]);

        // Fixed OTP check as requested
        if ($request->otp !== '1234') {
            return response()->json(['message' => 'Invalid OTP.'], 422);
        }

        $user = User::where('phone', $request->phone)->first();

        if (!$user || !$user->otp_status) {
            return response()->json(['message' => 'User not found or profile incomplete. Please register.'], 404);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => $user
        ]);
    }

    public function me(Request $request)
    {
        return response()->json($request->user());
    }
}
