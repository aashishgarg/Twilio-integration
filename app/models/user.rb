class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:phone_no]

  # ============== Validations ================================== #
  validates :phone_no, presence: true, uniqueness: true, length: {minimum: 10, maximum: 10}

  # ============== Attribute Accessors ========================== #
  attr_accessor :skip_password_validation

  # ============== Callbacks ==================================== #
  before_create :set_refresh_token
  after_create :remove_otp_data_from_cache

  # ============== Constants ==================================== #
  AUTH_TOKEN_EXPIRY_TIME = 15.days
  OTP_EXPIRY_TIME = 5.days
  DEVELOPMENT_TEST_OTP = '777777' #---> For development mode testing only.

  def profile_completed?
    self.email.present?
  end

  private
  def set_refresh_token
    self.refresh_token = SecureRandom.base64(12)
  end

  def remove_otp_data_from_cache
    CacheManagement.instance.delete_value(self.phone_no)
  end

  def password_required?
    false
  end

  def email_required?
    false
  end
end
