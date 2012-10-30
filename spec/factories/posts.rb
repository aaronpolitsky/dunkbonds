Factory.define :post do |p|
  p.title "blah"
  p.content "blahblah"
  p.published_at DateTime.now
  p.url "url"
end
