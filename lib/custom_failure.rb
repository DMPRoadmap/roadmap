# frozen_string_literal: true

<<<<<<< HEAD
class CustomFailure < Devise::FailureApp

=======
# Override how Devise handles failures
class CustomFailure < Devise::FailureApp
>>>>>>> upstream/master
  def redirect_url
    root_path
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
<<<<<<< HEAD

=======
>>>>>>> upstream/master
end
