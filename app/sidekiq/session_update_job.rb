class SessionUpdateJob
  include Sidekiq::Job

  def perform(ds_session_id, otp_code)
    session = ThreeDsSession.find_by(uuid: ds_session_id)

    driver = ::SeleniumExtra.connect_to_existing_session(session.selenium_session_id)

    wait = ::Selenium::WebDriver::Wait.new(timeout: 10)
    element = wait.until { 
      el = driver.find_element(:css, '.cp-otp-input-container') 
      el.displayed? ? el : nil  # Ensure it's visible
    }

    otp_code.chars.each_with_index do |digit, index|
      field = driver.find_element(id: "otpPart#{index + 1}")
      field.send_keys(digit)
      sleep 2
    end
  end
end
