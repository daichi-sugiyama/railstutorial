class ApplicationController < ActionController::Base
  def hello
    render html:"hello sample application!"
  end
end
