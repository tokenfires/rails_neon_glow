# frozen_string_literal: true

require "selenium-webdriver"
require "capybara/selenium/driver"

# Capybara 3.40 clears storage with origin "*", which Chrome 158 rejects.
# Discard the entire browser session in that case so cookies and storage cannot
# leak between tests. Remove this fallback when Capybara supports the new API.
module ChromeStorageReset
  def reset!
    super
  rescue Selenium::WebDriver::Error::InvalidArgumentError => error
    raise unless error.message.include?("* is not a valid URL")

    window_size = browser.manage.window.size
    quit
    browser.manage.window.size = window_size
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeStorageReset)
