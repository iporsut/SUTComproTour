class LoginController < ApplicationController

  def index
    # show login screen
    reset_session
    redirect_to :controller => 'main', :action => 'login'
  end

  def login
    if user = User.authenticate(params[:login], params[:password])
      session[:user_id] = user.id
      session[:admin] = user.admin?
      redirect_to :controller => 'main', :action => 'list'
    else
      flash[:notice] = 'Wrong password'
      redirect_to :controller => 'main', :action => 'login'
    end
  end

  def site_login
    begin
      site = Site.find(params[:login][:site_id])
    rescue ActiveRecord::RecordNotFound
      site = nil
    end
    if site==nil
      flash[:notice] = 'Wrong site'
      redirect_to :controller => 'main', :action => 'login'  and return
    end
    if (site.password) and (site.password == params[:login][:password])
      session[:site_id] = site.id
      redirect_to :controller => 'site', :action => 'index'
    else
      flash[:notice] = 'Wrong site password'
      redirect_to :controller => 'site', :action => 'login'
    end
  end

end
