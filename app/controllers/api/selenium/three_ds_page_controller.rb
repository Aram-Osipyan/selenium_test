module Api
  module Selenium
    class ThreeDsPageController < ApplicationController
      def show
        model = ThreeDsSession.find_by(uuid: params[:id])

        @creq = creq = model.creq
        # html_content = render_to_string(template: "three_d_secure/creq_page", layout: false).sub(/\A<!-- BEGIN .*? -->\n/, "")

        # render html: html_content

        render template: 'three_d_secure/creq_page', layout: false
        # render template: 'pages/home', layout: false
        # render plain: "<html><body>Loading...</body></html>"
      end
    end
  end
end
