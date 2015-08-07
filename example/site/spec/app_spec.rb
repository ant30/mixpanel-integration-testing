require_relative "spec_helper"
require_relative "../app.rb"

describe "Generic app test" do
  it "Index smoke test" do
    get '/'
    expect(last_response).to be_ok
  end
end
