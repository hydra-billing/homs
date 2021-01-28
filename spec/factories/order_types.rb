FactoryBot.define do
  factory :order_type do
    initialize_with do
      new(file: {
        order_type: {
          code:            'Without custom fields',
          name:            'Empty order type',
          print_form_code: 'print_form_code',
          fields:          {}
        }
      }.to_yaml)
    end

    trait :active do
      active true
    end

    trait :vacation_request do
      active true
      code 'Vacation request'
      fields(vacationLeaveDate: {
               type:        'datetime',
               label:       'Leave date',
               description: 'Leave date',
               required:    true,
               multiple:    false,
               visible:     true,
               editable:    true
             },
             vacationBackDate:  {
               type:        'datetime',
               label:       'Vacation end date',
               description: 'Vacation end date',
               required:    true,
               multiple:    false,
               visible:     true,
               editable:    true
             },
             employee:          {
               type:        'string',
               label:       'Employee',
               description: 'Employee',
               required:    true,
               multiple:    false,
               visible:     true,
               editable:    true
             },
             approver:          {
               type:        'string',
               label:       'Approver',
               description: 'Approver',
               required:    true,
               multiple:    false,
               visible:     true,
               editable:    true
             })
    end

    trait :support_request do
      active true
      code 'Support Request'
      print_form_code 'print_form_code'
      fields(
        creationDate:       {
          type:        'datetime',
          label:       'Creation date',
          description: 'Creation date'
        },
        problemDescription: {
          type:        'string',
          label:       'Problem description',
          description: 'Problem description'
        },
        callBack:           {
          type:        'boolean',
          label:       'Callback',
          description: 'Callback'
        },
        contractNumber:     {
          type:        'number',
          label:       'Contract number',
          description: 'Contract number'
        }
      )
    end

    trait :new_customer do
      active true
      code 'New customer'
      fields(
        customerCity:       {
          type:  'string',
          label: 'Customer City'
        },
        customerStreet:     {
          type:  'string',
          label: 'Customer Street'
        },
        customerHouse:      {
          type:  'string',
          label: 'Customer House'
        },
        customerEntrance:   {
          type:  'string',
          label: 'Customer Entrance'
        },
        addressIsAvailable: {
          type:  'boolean',
          label: 'Customer address is available'
        },
        planId:             {
          type:  'number',
          label: 'Customer Plan'
        },
        planComment:        {
          type:  'string',
          label: 'Comment to plan'
        },
        customerName:       {
          type:  'string',
          label: 'Customer Name'
        },
        customerSurname:    {
          type:  'string',
          label: 'Customer Surname'
        },
        customerPhone:      {
          type:  'string',
          label: 'Customer Phone'
        },
        customerEmail:      {
          type:  'string',
          label: 'Customer Email'
        },
        installDate:        {
          type:  'datetime',
          label: 'Install date'
        },
        fromFriends:        {
          type:  'boolean',
          label: 'Friends'
        },
        fromTV:             {
          type:  'boolean',
          label: 'TV'
        },
        fromFacebookAds:    {
          type:  'boolean',
          label: 'Facebook Ads'
        },
        fromOther:          {
          type:  'boolean',
          label: 'Other'
        },
        fileList:           {
          type:  'json',
          label: 'Attached files'
        },
        uploadedFile:       {
          type:  'json',
          label: 'Attach file'
        }
      )
    end
  end
end
