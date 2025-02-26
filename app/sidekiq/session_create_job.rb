class SessionCreateJob
  include Sidekiq::Job

  def perform(ds_session_id)
    session = ThreeDsSession.find(ds_session_id)

    driver = ::SeleniumExtra.connect_to_existing_session(session.selenium_session_id)

    driver.get("http://web:8000/api/selenium/three_ds_page/#{session.uuid}")

    wait = ::Selenium::WebDriver::Wait.new(timeout: 10)
    element = wait.until { 
      el = driver.find_element(:css, '.cp-otp-input-container') 
      el.displayed? ? el : nil  # Ensure it's visible
    }
  end
end
