json.attachments do
  json.partial! partial: 'api/v1/attachments/attachment',
                collection: attachments, as: :attachment
end
