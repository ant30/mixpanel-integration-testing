require_relative "spec_helper"
require "mixpaneltesting"

describe "Mixpaneltesting environment" do
  include_context "mixpaneltesting"

  @localurl = ENV["LOCAL_URL"]

  describe "Simple session with one interation (click)" do

    it "Expected 2 page views/1 click" do
      @selenium.waitfor_object_displayed(:tag_name, 'title')
      @selenium.click(:link_text => 'Page 1')

      expect(@selenium.get_page_source).to match(/<title>Page 1<\/title>/)

      expect(@mixpanel.validate_results({
        'PageView' => 2,
        'ClickInteraction' => 1
      })).to be true
    end
  end

  describe "Full session from init to thankyou page" do

    it "Expected 4 page views/3 clicks" do
      @selenium.waitfor_object_displayed(:tag_name, 'title')

      @selenium.click(:link_text => 'Page 1')
      expect(@selenium.get_page_source).to match(/<title>Page 1<\/title>/)

      @selenium.click(:link_text => 'Page 2')
      expect(@selenium.get_page_source).to match(/<title>Page 2<\/title>/)

      @selenium.click(:link_text => 'Thank you page')
      expect(@selenium.get_page_source).to match(/<title>Thank you page<\/title>/)

      expect(@mixpanel.validate_results({
        'PageView' => 4,
        'ClickInteraction' => 3
      })).to be true
    end
  end

end
