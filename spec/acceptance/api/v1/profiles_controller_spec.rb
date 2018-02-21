require 'acceptance_helper'

describe API::V1::ProfilesController, type: :request do
  resource I18n.t('doc.profiles.resource') do
    include HttpAuthHelper

    let(:order_type) { FactoryGirl.create(:order_type, :support_request) }
    let(:john)       { FactoryGirl.create(:user, :john) }
    let(:frank)      { FactoryGirl.create(:user, :frank) }

    before(:each) do
      disable_http_basic_authentication(API::V1::ProfilesController)

      profile = Profile.new(order_type_id: order_type.id, user_id: john.id)
      profile.data = {
          contractNumber:     {type: 'number',   label: 'Contract number',     show: true},
          problemDescription: {type: 'string',   label: 'Problem description', show: true},
          creationDate:       {type: 'datetime', label: 'Creation date',       show: true},
          callBack:           {type: 'boolean',  label: 'Callback',            show: true}
      }
      profile.save
    end

    header 'Accept',       'application/json'
    header 'Content-Type', 'application/json'

    get '/api/profiles?page_size=:page_size&page=:page' do
      parameter :page_size,
                I18n.t('doc.common.parameters.page_size'),
                {I18n.t('doc.common.parameters.default') => 25}
      parameter :page,
                I18n.t('doc.common.parameters.page'),
                {I18n.t('doc.common.parameters.default') => 1}

      example_request I18n.t('doc.common.cases.list'),
                      page_size: 2, page: 1 do
        expect(status).to eq(200)
        expect((JSON response_body)['profiles'].map { |e| e['order_type_code'] }).to eq([order_type.code])

        profile = (JSON response_body)['profiles'].first
        expect(profile).to eq({
                                'id'                  => Profile.by_order_type_and_user(order_type.id, john.id).id,
                                'data'                => {
                                    'contractNumber'     => {'type' => 'number',   'label' => 'Contract number',     'show'=> true},
                                    'problemDescription' => {'type' => 'string',   'label' => 'Problem description', 'show'=> true},
                                    'creationDate'       => {'type' => 'datetime', 'label' => 'Creation date',       'show'=> true},
                                    'callBack'           => {'type' => 'boolean',  'label' => 'Callback',            'show'=> true}
                                },
                                'order_type_code'     => 'Support Request',
                                'user_email'          => 'j.doe@example.com'
                            })
      end
    end

    get '/api/profiles/:id' do
      parameter :id,
                I18n.t('doc.profiles.parameters.id'),
                required: true

      let(:id) { Profile.by_order_type_and_user(order_type.id, john.id).id }

      example_request I18n.t('doc.common.cases.show') do
        expect(status).to eq(200)
        profile = (JSON response_body)
        expect(profile).to eq({
                                'profile' => {
                                    'id'                  => id,
                                    'data'                => {
                                        'contractNumber'     => {'type' => 'number',   'label' => 'Contract number',     'show'=> true},
                                        'problemDescription' => {'type' => 'string',   'label' => 'Problem description', 'show'=> true},
                                        'creationDate'       => {'type' => 'datetime', 'label' => 'Creation date',       'show'=> true},
                                        'callBack'           => {'type' => 'boolean',  'label' => 'Callback',            'show'=> true}
                                    },
                                    'order_type_code'     => 'Support Request',
                                    'user_email'          => 'j.doe@example.com'
                                }
                            })
      end
    end

    post '/api/profiles' do
      parameter :user_email,
                I18n.t('doc.profiles.parameters.user_email'),
                scope: :profile
      parameter :order_type_code,
                I18n.t('doc.profiles.parameters.order_type_code'),
                scope: :profile
      parameter :data,
                I18n.t('doc.profiles.parameters.data'),
                scope: :profile

      let(:user)            { frank }
      let(:user_email)      { user.email }
      let(:order_type_code) { order_type.code }
      let(:data) do
        {
            'contractNumber'     => {'type' => 'number',   'label' => 'Contract number',     'show'=> false},
            'problemDescription' => {'type' => 'string',   'label' => 'Problem description', 'show'=> true},
            'creationDate'       => {'type' => 'datetime', 'label' => 'Creation date',       'show'=> false},
            'callBack'           => {'type' => 'boolean',  'label' => 'Callback',            'show'=> true}
        }
      end

      example_request I18n.t('doc.common.cases.create') do
        expect(status).to eq(201)

        profile = Profile.by_order_type_and_user(order_type.id, user.id)
        expect(profile.id).not_to eq(nil)
        expect(profile.data).to   eq(data)

        expect(JSON response_body).to eq({
                                             'profile' => {
                                                 'id'              => profile.id,
                                                 'data'            => profile.data,
                                                 'order_type_code' => profile.order_type.code,
                                                 'user_email'      => profile.user.email
                                             }
                                         })
      end
    end

    put '/api/profiles/:id' do
      parameter :id,
                I18n.t('doc.profiles.parameters.id'),
                scope: :profile
      parameter :user_email,
                I18n.t('doc.profiles.parameters.user_email'),
                scope: :profile,
                required: true
      parameter :order_type_code,
                I18n.t('doc.profiles.parameters.order_type_code'),
                scope: :profile
      parameter :data,
                I18n.t('doc.profiles.parameters.data'),
                scope: :profile

      let(:id)              { Profile.by_order_type_and_user(order_type.id, john.id).id }
      let(:order_type_code) { order_type.code }
      let(:user_email)      { john.email }
      let(:data) do
        {
            'contractNumber'     => {'type' => 'number',   'label' => 'Contract number',     'show'=> false},
            'problemDescription' => {'type' => 'string',   'label' => 'Problem description', 'show'=> false},
            'creationDate'       => {'type' => 'datetime', 'label' => 'Creation date',       'show'=> false},
            'callBack'           => {'type' => 'boolean',  'label' => 'Callback',            'show'=> false}
        }
      end

      example_request I18n.t('doc.common.cases.update') do

        expect(status).to eq(200)

        updated_profile = Profile.find(id)
        expect(updated_profile.data).to eq({
                                             'contractNumber'     => {'type' => 'number',   'label' => 'Contract number',     'show'=> false},
                                             'problemDescription' => {'type' => 'string',   'label' => 'Problem description', 'show'=> false},
                                             'creationDate'       => {'type' => 'datetime', 'label' => 'Creation date',       'show'=> false},
                                             'callBack'           => {'type' => 'boolean',  'label' => 'Callback',            'show'=> false}
                                           })

        expect(JSON response_body).to eq(
                                          'profile' => {
                                              'id'                  => updated_profile.id,
                                              'data'                => updated_profile.data,
                                              'order_type_code'     => updated_profile.order_type.code,
                                              'user_email'          => updated_profile.user.email
                                          })
      end
    end
  end
end
