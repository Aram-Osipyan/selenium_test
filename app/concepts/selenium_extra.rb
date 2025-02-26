class SeleniumExtra
  def self.connect_to_existing_session(session_id, url = "http://selenium:4444/wd/hub")
    bridge = Selenium::WebDriver::Remote::W3C::Bridge.new(
      Selenium::WebDriver::Remote::Capabilities.chrome, 
      session_id, 
      url: 
    )

    Selenium::WebDriver::Driver.new(bridge)
  end

  def self.get_driver_session_id(driver)
    driver.session_storage.instance_variable_get(:@bridge).instance_variable_get(:@session_id)
  end
end