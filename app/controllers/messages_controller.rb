class MessagesController < ApplicationController

  # ================= Skip before actions ================= #
  skip_before_action :verify_authenticity_token
  skip_before_action :current_user, only: [:register_mobile]


=begin
  *******************************************************
  # POST /register_mobile.json
  # Params -
          {
            "user": {
              "phone_no": "9555604380",
              "country_code": "+91"

            }
          }
  *******************************************************
=end
  def register_mobile
    otp = SecureRandom.random_number(1000000)
    CacheManagement.instance.set_value(params[:user][:phone_no], otp, User::OTP_EXPIRY_TIME)

    begin
      otp_message = "Your one time password is #{otp}"
      message = send_message(params[:user][:country_code], params[:user][:phone_no], otp_message)
      render status: :ok, json: {message: 'OTP sent successfully.'}
    rescue => e
      render status: :ok, json: {error: e.message}
    end
  end

  private
  def send_message(country_code, number, message)
    settings = YAML.load_file(File.join(Rails.root, 'config', 'twilio.yml'))[Rails.env]
    @client = Twilio::REST::Client.new(settings["twilio_account_sid"], settings["twilio_auth_token"])
    @client.messages.create(from: settings["twilio_phone_number"], to: (country_code + number), body: message)
  end

  def user_params
    params.require(:user).permit(:phone_no)
  end
end
