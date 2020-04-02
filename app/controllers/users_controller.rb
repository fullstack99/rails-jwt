class UsersController < ApplicationController
  before_action :authorize_request, except: :create
  before_action :find_user, except: %i[create index]

  # GET /users
  def index
    @permission = @current_user.permission

    @users = User.all
    if @permission == 'user'
      @users = User.find_by_id(@current_user.id)    
    end 
    
    render json: @users, status: :ok
  end

  # GET /users/{username}
  def show
    @permission = @current_user.permission

    if @permission != 'admin' && params[:_username] != @current_user.username
      render json: { message: 'You dont have permission' },
              status: :unprocessable_entity
    else 
      render json: @user, status: :ok  
    end
    
  end

  # POST /users
  def create
    client = Nexmo::Client.new(
      api_key: "6e1ea2fc",
      api_secret: "1BIyowRXerM5FfpV"
    )

    result = client.verify.request(
      number: '18064968476',
      brand: "Kittens and Co",
      code_length: '6'
    )

    if result.status == '0'
      @user = User.new(user_params)
      if @user.save
        render json: { message: 'success', success: true, request_id: result['request_id'] }, status: :created
      else
        render json: { errors: @user.errors.full_messages },
               status: :unprocessable_entity
      end
    else
      render json: { message: result.error_text, success: false }, status: :unprocessable_entity      
    end

  end

  # PUT /users/{username}
  def update
    @permission = @current_user.permission
    if @permission != 'admin' && params[:_username] != @current_user.username
      render json: { message: 'You dont have permission' },
              status: :unprocessable_entity
    else

      if @user.update(user_params)
        render json: { message: 'success', success: true }, status: :ok
      else
        render json: { errors: @user.errors.full_messages },
             status: :unprocessable_entity
      end  
    end    

  end

  # DELETE /users/{username}
  def destroy
    @permission = @current_user.permission
    
    if @permission !='admin' && params[:_username] != @current_user.username      
      render json: { message: 'You dont have permission' },
              status: :unprocessable_entity
    else 
      @user.destroy
    end
  end

  private

  def find_user
    @user = User.find_by_username!(params[:_username])
    rescue ActiveRecord::RecordNotFound
      render json: { errors: 'User not found' }, status: :not_found
  end

  def user_params
    params.permit(
      :avatar, :name, :username, :email, :password, :password_confirmation, :phone_number
    )
  end
end