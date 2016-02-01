json.array!(@events) do |event|
  json.extract! event, :id, :date_at, :date_to, :title, :description
  json.url event_url(event, format: :json)
end
