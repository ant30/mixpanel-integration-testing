require_relative "spec_helper"
require_relative "../app.rb"

describe "Smoke tests" do
  it "Index smoke test" do
    get '/'
    expect(last_response).to be_ok
  end
  it "Page 1 smoke test" do
    get '/page1'
    expect(last_response).to be_ok
  end
  it "Page 2 smoke test" do
    get '/page2'
    expect(last_response).to be_ok
  end
  it "Thank you page smoke test" do
    get '/thankyou'
    expect(last_response).to be_ok
  end
end


describe "Correct title in views tests" do
  it "Index page title test" do
    get '/'
    expect(last_response).to match(/<title>Index Page<\/title>/)
  end
  it "Page 1 title test" do
    get '/page1'
    expect(last_response).to match(/<title>Page 1<\/title>/)
  end
  it "Page 2 title test" do
    get '/page2'
    expect(last_response).to match(/<title>Page 2<\/title>/)
  end
  it "Thank you page title test" do
    get '/thankyou'
    expect(last_response).to match(/<title>Thank you page<\/title>/)
  end
end
