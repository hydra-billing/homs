json.profiles do
  json.partial! partial: 'api/v1/profiles/profile', collection: @profiles, as: :profile
end
