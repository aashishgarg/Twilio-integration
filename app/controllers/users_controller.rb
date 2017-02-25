class UsersController < ApplicationController

  # ============= Skip before actions ============= #
  skip_before_action :verify_authenticity_token
  skip_before_action :current_user, only: [:new_auth_token]


  # POST /new_auth_token.json
  # Params - {refresh_token: '12gsdjfgjh2342j3h4gj'}
  def new_auth_token
    new_auth_token = SecureRandom.base64(12)
    user = User.where(refresh_token: params[:refresh_token]).take
    if user.present?
      CacheManagement.instance.set_value(new_auth_token, user.id, User::AUTH_TOKEN_EXPIRY_TIME)
      render status: :ok, json: {message: 'New auth token generated successfully.', auth_token: new_auth_token}
    else
      render status: :unauthorized, json: {error: 'Refresh token not valid.'}
    end
  end
end
