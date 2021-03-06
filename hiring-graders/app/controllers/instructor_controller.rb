class InstructorController < ApplicationController
  before_action :is_instructor?
  skip_before_action :is_instructor?, only: [:login, :create]
  
  def create

    # Check if account with that email already exists
    error = false
    @existing_student = Student.find_by(email: params[:email])
    @existing_admin = Admin.find_by(email: params[:email])
    if @existing_student != nil || @existing_admin != nil
      error = true
    end

    # Create the account and display the appropriate message if there is an error
    if !error
      @instructor = Instructor.new(first_name: params[:fName], last_name: params[:lName], email: params[:email],
        password: params[:password], password_confirmation: params[:confirmPassword])
      if @instructor.save
        log_in @instructor, 'instructor'
        redirect_to :action => 'profile'
      else
        flash[:danger] = @instructor.errors.full_messages
        redirect_to '/user/signup'
      end
    else
      flash[:danger] = "This email is tied to an existing account. Please log in above."
      redirect_to '/user/login'
    end

  end
  
  # Login in the instructor user by authenticating with db and saving id in session
  def login
    instructor = Instructor.find_by(email: params[:email].downcase)
    if instructor && instructor.authenticate(params[:password])
      log_in instructor, 'instructor'
      redirect_to '/instructor/profile'
    else
      flash[:danger] = "Invalid email/password combination"
      redirect_to '/user/login'
    end
  end

  # Rec form
  def recommendation
  end

  # Add a new recommendation to the database
  def create_recommendation
    instructor_id = Instructor.find_by(email: session[:user_email]).id
    
    # Determine if the request checkbox was selected
    rec_request = false
    if params[:recRequest]
      rec_request = true
    end

    # create the recommendation
    @recommend = Recommendation.new(recommendation: params[:recText], student_email: params[:email], first_name: params[:firstName],
                                    last_name: params[:lastName], course_number: params[:recCourse], instructor_id: instructor_id, request: rec_request)

    if @recommend.save
      flash[:success] = "Your recommendation was saved successfully!"
      redirect_to '/instructor/profile'
    else
      flash.now[:danger] = @recommend.errors.full_messages
      render '/instructor/recommendation'
    end
  end

  # Update an existing recommendation
  def update_recommendation
    instructor_id = Instructor.find_by(email: session[:user_email]).id

    # Determine if the request checkbox was selected
    rec_request = false
    if params[:recRequest]
      rec_request = true
    end
    recommendation = Recommendation.find_by(id: params[:id])
    if recommendation.update(recommendation: params[:recText], student_email: params[:email], first_name: params[:firstName],
                          last_name: params[:lastName], course_number: params[:recCourse], instructor_id: instructor_id, request: rec_request)
      flash[:success] = "Your recommendation was updated successfully!"
      redirect_to '/instructor/edit_recommendation'

    else
      flash[:danger] = recommendation.errors.full_messages
      redirect_to "/instructor/edit/#{params[:id]}"
    end

  end


  # Retrieve all the submitted recommendations by the instructor to show in the edit recommendations view
  def edit_recommendation
    instructor_id = Instructor.find_by(email: session[:user_email]).id
    @recommendations = Recommendation.where(instructor_id: instructor_id)
  end

  # Retrieve the specific recommendation form that is to be edited
  def edit
    @recommendation = Recommendation.find_by(id: params[:id])
  end

  def evaluation
  end

  def create_evaluation
    # check that the student/section exists
    student = Student.find_by(email: params[:email])
    course = Course.find_by(section_number:params[:section_num])
    instructor_id = Instructor.find_by(email: session[:user_email]).id

    if student == nil
      flash.now[:danger] = "It looks like that student has not graded before. Please enter a valid grader's email."
      render '/instructor/evaluation'
    elsif course == nil
      flash.now[:danger] = "Unable to find that section. Please enter a valid section number"
      render '/instructor/evaluation'
    else
      evaluation = Evaluation.new(student_id: Student.find_by(email:params[:email]).id, 
                                    instructor_id: instructor_id, 
                                    course_id: Course.find_by(section_number: params[:section_num]).id,
                                    quality: params[:quality],
                                    punctuality: params[:punctuality],
                                    com_skills: params[:com_skills],
                                    course_knowledge: params[:knowledge])
      if evaluation.save
        flash[:success] = "Your evaluation was sucessfully saved"
        redirect_to '/instructor/profile'
      else
        flash[:danger] = evaluation.errors.full_messages
        redirect_to '/instructor/evaluation'

      end
    end
  end


  def evaluation_all
    instructor_id = Instructor.find_by(email: session[:user_email]).id
    @evaluations = Evaluation.where(instructor_id: instructor_id)
  end

  def evaluation_edit
    @evaluation = Evaluation.find_by(id: params[:id])
  end

  def update_evaluation
    student = Student.find_by(email: params[:email])
    course = Course.find_by(section_number:params[:section_num])
    instructor_id = Instructor.find_by(email: session[:user_email]).id
    
    if student == nil
      flash[:danger] = "It looks like that student has not graded before. Please enter a valid grader's email."
      redirect_to "/instructor/edit_evaluation/#{params[:id]}"
    elsif course == nil
      flash[:danger] = "Unable to find that section. Please enter a valid section number"
      redirect_to "/instructor/edit_evaluation/#{params[:id]}"
      
    else
      evaluation = Evaluation.find_by(id: params[:id])
      if evaluation.update(student_id: Student.find_by(email:params[:email]).id, 
                          instructor_id: instructor_id, 
                          course_id: Course.find_by(section_number: params[:section_num]).id,
                          quality: params[:quality],
                          punctuality: params[:punctuality],
                          com_skills: params[:com_skills],
                          course_knowledge: params[:knowledge])
        flash[:success] = "Your evaluation was updated successfully!"
        redirect_to '/instructor/evaluation_all'

      else
        flash.now[:danger] = evaluation.errors.full_messages
      end
    end
    
  end

  # Instructor Profile 
  def profile
    @instructor = Instructor.find_by email: session[:user_email]
    @instructor_name = "#{@instructor.first_name} #{@instructor.last_name}"
  end

  # Check if the user has an instructor account
  def is_instructor?
    if !session[:user_email] && !Instructor.find_by(email: session[:user_email])
      redirect_to '/user/signup'
    end
  end

end
