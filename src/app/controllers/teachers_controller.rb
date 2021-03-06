
# Inclui o módulo com as definições de aspectos.
include ASPECTS

class TeachersController < ApplicationController
  before_action :set_teacher, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  
  #----------------------------------------------------------------------------- #
  # sintaxe equivalente do framawork ruby on rails ao pointcut de AOP.           #
  # o método user_can_be_teacher será executado apenas quando o método new          #
  # for disparado;                                                               #
  #----------------------------------------------------------------------------- #
  
  # JoinPoint :class => TeacherController, :method => new
  around_action :user_can_be_teacher, only: :new
  
  def index
    
    if ( (params[:area]) and (!params[:area][:id].eql? "") )
      area_id = params[:area][:id] 
        # @areas = AreaOfKnowledge.joins(' JOIN matters ON area_of_knowledges.id = matters.areaOfKnowledge_id').distinct
        # @materias = Matter.where("matters.areaOfKnowledge_id = ? ", area_id )
        
        # @teachers  = Teacher.joins('LEFT OUTER JOIN courses ON teachers.id = courses.teacher_id').
        #       where("courses.id IN (?)", 
        #         Course.where("matter_id IN (?) ", 
        #           Matter.where("matters.areaOfKnowledge_id = ? ", 
        #             area_id).select(:id) ).select(:id)).distinct
        
        @teachers  = FACADE.Professor.joins_and_where_in(
                        'LEFT OUTER JOIN courses ON teachers.id = courses.teacher_id',
                        "courses.id IN (?)", 
                        FACADE.Curso.where("matter_id IN (?) ", 
                            FACADE.Materia.where("matters.areaOfKnowledge_id = ? ", area_id).select(:id) 
                        ).select(:id) 
                    )
    end

    
    if (params[:materia]) and (!params[:materia][:id].eql? "")
      
        materia_id = params[:materia][:id] 
        @teachers  = Teacher.joins('LEFT OUTER JOIN courses ON teachers.id = courses.teacher_id').
              where("courses.id IN (?)", 
              Course.where("matter_id =  ?",materia_id).select(:id)).distinct
    end
      
      @teachers ||= FACADE.getAll("teacher")  # @teachers ||= Teacher.all
      @materias ||= FACADE.getAll("matter") # @materias ||= Matter.all
      
      # @areas ||= FACADE.AreaConhecimento.joins(' JOIN matters ON area_of_knowledges.id = matters.areaOfKnowledge_id').distinct
      # @areas ||= FACADE.AreaConhecimento.where_IN( "id IN (?)", @materias.select(:areaOfKnowledge_id)).distinct
      @areas ||= FACADE.AreaConhecimento.all
      
     
      
      @cursos ||= FACADE.getAll("course")                 # @cursos ||= Course.all
      @matriculas ||= FACADE.getAll("enrollment")         # @matriculas ||= Enrollment.all
      @recomendacoes ||= FACADE.getAll("recommendation")  # @recomendacoes ||= Recommendation.all
    
    
  end

 
  def show

    # @aulas = Course.where( "teacher_id = ? ", @teacher.id)
    @aulas = FACADE.Curso.where( "teacher_id = ?", @teacher.id)
    
    # @ultimas_aulas = Enrollment.where("course_id in ( ? )", @aulas.select(:id) ).limit(5)
    @ultimas_aulas = FACADE.Matricula.where("course_id in ( ? )", @aulas.select(:id) ).limit(5)
    
    # @aulas_realizadas = Enrollment.where("id NOT IN ( ? ) AND course_id in ( ? )", @ultimas_aulas.select(:id),@aulas.select(:id) )
    @aulas_realizadas = FACADE.Matricula.where("id NOT IN ( ? ) AND course_id in ( ? )", @ultimas_aulas.select(:id),@aulas.select(:id) )
    
    # @minhas_aulas = Enrollment.where("course_id in ( ? )", @aulas.select(:id) )
    @minhas_aulas = FACADE.Matricula.where("course_id in ( ? )", @aulas.select(:id) )
   
    @horas_aulas = 0
    @minhas_aulas.each do |aula|
      @horas_aulas = @horas_aulas + aula.hours 
		end
		
		# @cursos ||= Course.all
		@cursos ||= FACADE.Curso.all
		
    # @matriculas ||= Enrollment.all
    @matriculas ||= FACADE.Matricula.all
    
    # @recomendacoes ||= Recommendation.all
    @recomendacoes ||= FACADE.Recomendacao.all
		
		@positivas = @recomendacoes.where("rating = 1 AND enrollment_id IN (?) ",
                                            @matriculas.where("course_id IN (?)",
                                              @cursos.where("teacher_id = ? ", @teacher.id).select(:id)
                                                  ).select(:id) 
                                                    ).count
		
		@negativas = @recomendacoes.where("rating = 0 AND enrollment_id IN (?) ",
                                            @matriculas.where("course_id IN (?)",
                                              @cursos.where("teacher_id = ? ",@teacher.id).select(:id)
                                              ).select(:id)).count
         
         
    if (@positivas+@negativas > 0)                                           
      @porcentagem = (@positivas*100)/(@positivas+@negativas)
    else
      @porcentagem = 0
    end
   
  end

 
  def new
    #-------------------------------------------------------------------------------------- #
    # esse método cria um novo professor, mais é necessário um teste para verificar se      #
    # o usuário atual do sistema (current_user) já não tem um perfil de professor.          #
    # para isso foi criada um medodo user_can_be_teacher e utilizado os requisos do framework  #
    # equivalentes a AOP, para realizar o teste e substituir a chamada ao metodo new        #
    # aqui declarado.                                                                       #
    #-------------------------------------------------------------------------------------- #
    
    # @teacher = Teacher.new
    # @teacher.user = User.find(current_user.id)
    @teacher = FACADE.Professor.new
    @teacher.user = FACADE.Usuario.get(current_user.id)
  end
  
  def edit
  end

  
  def create
    # @teacher = Teacher.new(teacher_params)
    @teacher = FACADE.Professor.new(teacher_params)
    
    @teacher.user = FACADE.Usuario.get(current_user.id)
    
    @teacher.user.avatar = params[:teacher][:avatar]
    @teacher.user.name = params[:teacher][:name]
    @teacher.user.scholarity = params[:teacher][:scholarity]
    @teacher.user.addrress = params[:teacher][:address]
    @teacher.user.state = params[:teacher][:state]
    @teacher.user.country = params[:teacher][:country]
    @teacher.user.date_of_birth = params[:teacher][:date_of_birth]
    @teacher.user.cpf = params[:teacher][:cpf]
    @teacher.user.fone = params[:teacher][:fone]
    @teacher.user.email = params[:teacher][:email]
    @teacher.user.whatsapp = params[:teacher][:whatsapp]
    @teacher.user.skype = params[:teacher][:skype]

    respond_to do |format|
      if @teacher.save
        
          @teacher.user.save
        
        format.html { redirect_to @teacher, notice: 'Parabéns! Agora você é um professor.' }
        format.json { render :show, status: :created, location: @teacher }
      else
        format.html { render :new }
        format.json { render json: @teacher.errors, status: :unprocessable_entity }
      end
    end
  end

  def update

    goback = params[:teacher][:redirect]
    
    respond_to do |format|
      if @teacher.update(teacher_params)
        if goback == "meuperfil"
          format.html { redirect_to "/meuperfil", notice: 'Professor atualizado com sucesso!' }
        else
          format.html { redirect_to @teacher, notice: 'Professor atualizado com sucesso!' }
          format.json { render :show, status: :ok, location: @teacher }
        end
      else
        format.html { render :edit }
        format.json { render json: @teacher.errors, status: :unprocessable_entity }
      end
    end
  end

 
  def destroy
    @teacher.destroy
    respond_to do |format|
      format.html { redirect_to teachers_url, notice: 'Teacher was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    
    def set_teacher
      # @teacher = Teacher.find(params[:id])
      @teacher = FACADE.Professor.get(params[:id])
    end

    def teacher_params
      params.require(:teacher).permit(:formation, :university, :description,  courses_attributes: [:id, :name, :_destroy], users_attributes: [:name, :cpf, :scholarity, :fone, :whatsapp, :skype, :addrress, :state, :country, :date_of_birth])
    end

end
