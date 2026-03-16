<?php

namespace App\Exports;

use App\Models\Lead;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;

class LeadsExport implements FromCollection, WithHeadings, WithMapping
{
    /**
    * @return \Illuminate\Support\Collection
    */
    public function collection()
    {
        return Lead::all();
    }

    public function headings(): array
    {
        return [
            'ID',
            'Business Name',
            'Owner Name',
            'Phone',
            'WhatsApp',
            'Email',
            'Website',
            'Instagram',
            'Facebook',
            'Maps Link',
            'Address',
            'City',
            'Category',
            'Status',
            'Created At'
        ];
    }

    public function map($lead): array
    {
        return [
            $lead->id,
            $lead->business_name,
            $lead->owner_name,
            $lead->phone,
            $lead->whatsapp,
            $lead->email,
            $lead->website,
            $lead->instagram,
            $lead->facebook,
            $lead->maps_link,
            $lead->address,
            $lead->city,
            $lead->category,
            $lead->status,
            $lead->created_at,
        ];
    }
}
