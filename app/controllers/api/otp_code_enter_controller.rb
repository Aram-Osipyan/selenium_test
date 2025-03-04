require 'sidekiq/api'

module Api
  class OtpCodeEnterController < ApplicationController
    def create
      otp_code = params[:otp_code]
      uuid = params[:uuid]

      model = ThreeDsSession.find_by(uuid:)

      return render json: { error: "Bad Request" }, status: :bad_request unless model
      return render json: { error: "Bad Request" }, status: :bad_request if model.state != 'otp_required'

      driver = ::SeleniumExtra.connect_to_existing_session(model.selenium_session_id)

      wait = ::Selenium::WebDriver::Wait.new(timeout: 10)
      element = wait.until {
        el = driver.find_element(:css, '.cp-otp-input-container') 
        el.displayed? ? el : nil  # Ensure it's visible
      }

      otp_code.chars.each_with_index do |digit, index|
        field = driver.find_element(id: "otpPart#{index + 1}")
        field.send_keys(digit)
        sleep 1
      end

      wait.until { driver.current_url.include?("https://app.mpay.azt") }

      model.complete!

      render json: { data: { uuid:  model.uuid, state: model.reload.state}}
    end
  end
end
