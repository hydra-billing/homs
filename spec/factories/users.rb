FactoryGirl.define do
  factory :user do
    confirmed_at Time.now
    company 'LLC Tools'
    password 'please123'
    password_confirmation 'please123'

    name 'Christopher'
    last_name 'Johnson'
    department 'Administrators'
    email 'c.johnson@example.com'

    trait :admin do
      role 'admin'
    end

    trait :john do
      name 'John'
      last_name 'Doe'
      department 'Marketing'
      email 'j.doe@example.com'
    end

    trait :frank do
      name 'Frank'
      last_name 'Poe'
      department 'Managers'
      email 'f.poe@example.com'
    end

    trait :david do
      name 'David'
      last_name 'Jones'
      department 'Demonstrations'
      email 'demo@example.com'
      company 'Example Corporation'
    end
  end
end
