class MattersController < ApplicationController
  before_action :set_matter, only: [:show, :edit, :update, :destroy]

  # GET /matters
  # GET /matters.json
  def index
    # @area_of_knowledges = AreaOfKnowledge.all
    # @matters = Matter.all
    # @courses = Course.all
    
    # @area_of_knowledges = FACADE.getAll("area_of_knowledge")
    # @matters = FACADE.getAll("matter")
    # @courses = FACADE.getAll("course")
    
    @area_of_knowledges = FACADE.AreaConhecimento.all
    @matters = FACADE.Materia.all
    @courses = FACADE.Curso.all
    
  end

  # GET /matters/1
  # GET /matters/1.json
  def show
    # @courses  = Course.where("matter_id = ? ", @matter.id)
    # @teachers = Course.where("matter_id = ? ", @matter.id).select(:teacher_id).distinct
    
    @courses  = FACADE.Curso.where("matter_id = ? ", @matter.id)
    @teachers = FACADE.Curso.where("matter_id = ? ", @matter.id).select(:teacher_id).distinct
  
  end

  # GET /matters/new
  def new
    # @matter = Matter.new
    @matter = FACADE.Materia.new
  end

  # GET /matters/1/edit
  def edit
  end

  # POST /matters
  # POST /matters.json
  def create
    # @matter = Matter.new(matter_params)
    @matter = FACADE.Materia.new(matter_params)
    
    respond_to do |format|
      if @matter.save
        format.html { redirect_to @matter, notice: 'Matter was successfully created.' }
        format.json { render :show, status: :created, location: @matter }
      else
        format.html { render :new }
        format.json { render json: @matter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /matters/1
  # PATCH/PUT /matters/1.json
  def update
    respond_to do |format|
      if @matter.update(matter_params)
        format.html { redirect_to @matter, notice: 'Matter was successfully updated.' }
        format.json { render :show, status: :ok, location: @matter }
      else
        format.html { render :edit }
        format.json { render json: @matter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /matters/1
  # DELETE /matters/1.json
  def destroy
    @matter.destroy
    respond_to do |format|
      format.html { redirect_to matters_url, notice: 'Matter was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_matter
      # @matter = Matter.find(params[:id])
      @matter = FACADE.Materia.get(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def matter_params
      params.require(:matter).permit(:name, :descripition, :created_at, :areaOfKnowledge_id)
    end
end
