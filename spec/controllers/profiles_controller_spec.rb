describe ProfilesController, type: :controller do
  let(:order_type) { FactoryBot.create(:order_type, :support_request) }
  let(:user)       { FactoryBot.create(:user) }
  let(:profile)    { FactoryBot.build(:profile, order_type: order_type, user: user) }

  describe 'Profiles' do
    it 'create success' do
      sign_in user

      profile.data['contractNumber'] = {type: 'number',   label: 'Contract number', show:  true}
      profile.data['creationDate']   = {type: 'datetime', label: 'Creation date',   show:  true}
      profile.data['callBack']       = {type: 'boolean',  label: 'Callback',        show:  false}

      post 'create', params: {order_type_id: profile.order_type.id, data: profile.data}
      expect(response.body).to eq(Profile.by_order_type_and_user(profile.order_type.id, profile.user.id).to_json)
      expect(profile.data.with_indifferent_access).to eq(Profile.by_order_type_and_user(profile.order_type.id, profile.user.id).data)
    end

    it 'update success' do
      sign_in user

      unless profile.save
        raise Exception('Profile is not saved')
      end

      expect(Profile.find(profile.id).data['contractNumber']).to eq(nil)
      expect(Profile.find(profile.id).data['creationDate']).to   eq(nil)
      expect(Profile.find(profile.id).data['callBack']).to       eq(nil)

      profile.data['contractNumber'] = {type: 'number',   label: 'Contract number', show:  true}
      profile.data['creationDate']   = {type: 'datetime', label: 'Creation date',   show:  true}
      profile.data['callBack']       = {type: 'boolean',  label: 'Callback',        show:  false}

      patch 'update', params: {id: profile.id, data: profile.data}

      expect(Profile.find(profile.id).data['contractNumber']).to eq({type: 'number',   label: 'Contract number', show:  true}.with_indifferent_access)
      expect(Profile.find(profile.id).data['creationDate']).to   eq({type: 'datetime', label: 'Creation date',   show:  true}.with_indifferent_access)
      expect(Profile.find(profile.id).data['callBack']).to       eq({type: 'boolean',  label: 'Callback',        show:  false}.with_indifferent_access)
    end
  end
end
