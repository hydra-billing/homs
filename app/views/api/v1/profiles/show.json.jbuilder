json.profile do
  json.partial! partial: 'api/v1/profiles/profile', locals: {profile: @profile}
end
