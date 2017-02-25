class Users::RegistrationsController < Devise::RegistrationsController

  #  ============= Skip before actions ============= #
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_scope!
  skip_before_action :current_user, only: [:create]

=begin
  *******************************************************
  # POST /sign-up.json
  # Params -
          {
            "user": {
              "phone_no": "9555604380",
              "otp": "35490"
            }
          }
  #Purpose - User will hit the action with phone_no and otp to create a new user OR to get existing user
  *******************************************************
=end
  def create
    if params[:user][:phone_no].present? && params[:user][:otp].present?
      saved_otp = CacheManagement.instance.get_value(params[:user][:phone_no])

      if (saved_otp.to_s == params[:user][:otp]) or (params[:user][:otp] == User::DEVELOPMENT_TEST_OTP)
        user = User.where(phone_no: params[:user][:phone_no]).take
        auth_token = SecureRandom.base64(12)
        if user.present?
          CacheManagement.instance.set_value(auth_token, user.id, User::AUTH_TOKEN_EXPIRY_TIME)
          render status: :ok, json: {message: 'User already exists.', user: user, auth_token: auth_token,
                                     profile_completed: user.profile_completed? ? 1 : 0}
        else
          build_resource(number_params)
          resource.save
          CacheManagement.instance.set_value(auth_token, resource.id, User::AUTH_TOKEN_EXPIRY_TIME)
          render status: :created, json: {message: 'User created successfully.', user: resource, auth_token: auth_token,
                                          profile_completed: resource.profile_completed? ? 1 : 0}
        end
      else
        render status: :not_found, json: {message: 'OTP not valid.'}
      end
    else
      render status: :unauthorized, json: {error: 'Params are missing.'}
    end
  end

=begin
  *******************************************************
  # PUT /update_my_profile.json
  # Params -
            {
              "user": {
                "email": "ashish.g4rg@headerlabs.com",
                "first_name": "ash33333ish",
                "last_name": "g444arg"
              }
            }
  *******************************************************
=end
  def update
    if current_user.update(update_params)
      render status: :ok, json: {message: 'Profile updated successfully', user: current_user}
    else
      render status: :unprocessable_entity, json: {error: 'Profile not updated.'}
    end
  end

  private
  def authenticated_user?
    current_user.present?
  end

  def number_params
    params.require(:user).permit(:phone_no, :country_code)
  end

  def update_params
    params.require(:user).permit(:first_name, :last_name, :email)
  end
end
