require 'sidekiq/api'

module Api
  class ThreeDSecureController < ApplicationController
    def create
      creq = params[:creq]

      capabilities = ::Selenium::WebDriver::Remote::Capabilities.chrome(
        # "goog:chromeOptions" => { "args" => ["--disable-gpu"] },
        # pageLoadStrategy: "none" # Don't wait for full page load
      )

      # logger = ::Selenium::WebDriver.logger
      # logger.level = :debug

      driver = ::Selenium::WebDriver.for(:chrome, 
        url: "http://selenium:4444/wd/hub", 
        desired_capabilities: capabilities
      )

      model = ThreeDsSession.create!(creq:, selenium_session_id: SeleniumExtra.get_driver_session_id(driver))

      jid = SessionCreateJob.perform_async(model.id)

      queue = Sidekiq::Queue.new  # Get default queue
      workers = Sidekiq::Workers.new  # Get currently running jobs

      while queue.map(&:jid).include?(jid) || workers.map { |_, _, w| w["payload"]["jid"] }.include?(jid)
        sleep 1
      end

      puts "Job has completed!"
      render json: { data: { uuid:  model.uuid, state: model.reload.state}}
    end

    def update
      otp_code = params[:otp_code]
      uuid = params[:id]

      model = ThreeDsSession.find_by(uuid:)

      render json: { error: "Bad Request" }, status: :bad_request unless model

      jid = SessionUpdateJob.perform_async(uuid, otp_code)

      queue = Sidekiq::Queue.new  # Get default queue
      workers = Sidekiq::Workers.new  # Get currently running jobs

      while queue.map(&:jid).include?(jid) || workers.map { |_, _, w| w["payload"]["jid"] }.include?(jid)
        sleep 1
      end

      render json: { data: { uuid:  model.uuid, state: model.reload.state}}
    end
  end
end
