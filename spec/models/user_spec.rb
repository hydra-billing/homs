describe User do
  before(:each) { @user = User.new(email: 'user@example.com') }

  subject { @user }

  it { should respond_to(:email) }

  it '#email returns a string' do
    expect(@user.email).to match 'user@example.com'
  end

  it '#id_from_email' do
    expect(User.id_from_email 'user@example.com').to match @user.id
    expect(User.id_from_email 'userr@example.com').to be_nil
  end

  it '.lookup' do
    users = [
      { last_name: 'Doe',      name: 'John',    middle_name: 'Mark'    },
      { last_name: 'Doe',      name: 'George',  middle_name: 'Simon'   },
      { last_name: 'Doe',      name: 'John',    middle_name: 'Jay'     },
      { last_name: 'Doe',      name: 'Andrew',  middle_name: 'Stanley' },
      { last_name: 'Moe',      name: 'Michael', middle_name: 'Itan'    },
      { last_name: 'Peterson', name: 'John',    middle_name: 'Rod'     },
      { last_name: 'Poe',      name: 'Frank',   middle_name: 'Jay'     }
    ]

    users.each_with_index do |user_hash, i|
      email = "user#{i}@mail.ru"
      create(:user, user_hash.merge(email: email))
    end

    expect(User.lookup('').count).to eq users.count
    expect(User.lookup('do').count).to eq 4
    expect(User.lookup('do').count).to eq 4
    expect(User.lookup('do').first.keys.sort).to eq [:id, :text]
    expect(User.lookup('do').map { |u| u[:text] }).to eq [
                                                             'Andrew Doe',
                                                             'George Doe',
                                                             'John Doe',
                                                             'John Doe'
                                                         ]
    expect(User.lookup('do', 2).map { |u| u[:text] }).to eq [
                                                                'Andrew Doe',
                                                                'George Doe'
                                                            ]
    expect(User.lookup('John').map { |u| u[:text] }).to eq [
                                                               'John Doe',
                                                               'John Doe',
                                                               'John Peterson'
                                                            ]
    expect(User.lookup('Jay').map { |u| u[:text] }).to eq [
                                                              'John Doe',
                                                              'Frank Poe'
                                                          ]
  end
end
