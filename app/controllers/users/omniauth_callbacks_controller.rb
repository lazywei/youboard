class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def self.provides_callback_for(*providers)
    providers.each do |provider|
      class_eval %Q{
        def #{provider}
          if not current_user.blank?
            current_user.bind_service(env["omniauth.auth"]) # Add an auth to existing
            current_user.update_token(env["omniauth.auth"])
            redirect_to root_path, :notice => "Successfully binded to #{provider}."
          else
            @user = User.find_or_create_for_#{provider}(env["omniauth.auth"])
            @user.update_token(env["omniauth.auth"])

            if @user.persisted?
              flash[:notice] = "Sign in with #{provider.to_s.titleize} successfully."
              sign_in_and_redirect @user, :event => :authentication, :notice => "Login successfully."
            else
              redirect_to new_user_registration_url
            end

          end
        end
      }
    end
  end

  provides_callback_for *Setting.providers

  # This is solution for existing accout want bind Google login but current_user is always nil
  # https://github.com/intridea/omniauth/issues/185
  def handle_unverified_request
    true
  end
end
