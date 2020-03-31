class AuthenticationController < ApplicationController
  before_action :authorize_request, except: [:login, :verification]

  # POST /auth/login
  def login
    @user = User.find_by_email(params[:email])
    if @user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: @user.id)
      time = Time.now + 24.hours.to_i
      render json: { token: token, exp: time.strftime("%m-%d-%Y %H:%M"),
                     username: @user.username }, status: :ok
    else
      render json: { error: 'unauthorized' }, status: :unauthorized
    end
  end

  def verification
    client = Nexmo::Client.new(
      api_key: "6e1ea2fc",
      api_secret: "1BIyowRXerM5FfpV"
    )

    confirmation = client.verify.check(
      request_id: params[:id],
      code: params[:code]
    )

    if confirmation['status'] == '0'
      @user = User.find_by_email(params[:email])
      @user.verification = true
      if @user.save
        render json: { message: 'phone verification success', success: true, id: result['request_id'] }, status: :ok
      else
        render json: { errors: @user.errors.full_messages },
               status: :unprocessable_entity
      end
    else
      render json: { errors:'phone verification failed', success: false, id:  params[:id]},
             status: :unprocessable_entity
    end
  end

  private

  def login_params
    params.permit(:email, :password)
  end

end
