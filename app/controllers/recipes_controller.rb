class RecipesController < ApplicationController

  def index
    @recipes = Recipe.all
    if params[:search]
      @recipes = Recipe.search(params[:search]).order("created_at DESC")
    else
      @recipes = Recipe.all.order("created_at DESC")
    end
  end

  def search

  end

  def new
    @recipe = Recipe.new
    @ingredients = current_ingredients_hash.map do |ingredient_hash|
      {inst: Ingredient.find(ingredient_hash["id"]), quantity: ingredient_hash["quantity"], unit: ingredient_hash["unit"]}
      #ingredient.id
    end
    @image = Image.new
  end

  def create
    @recipe = Recipe.new(recipe_params)
    @recipe.author_id = current_user.id
    current_ingredients.each do |ingredient|
      @recipe.ingredients << Ingredient.find(ingredient)
    end
    if params[:recipe][:image]
      @image = Image.create(image_params)
      @recipe.image_url = @image.image.url
    else
      @recipe.image_url = "https://s3.amazonaws.com/food-for-thought-bucket/mealIcon.jpg"
    end
    @recipe.save
    session.delete(:ingredients_list)
    redirect_to @recipe
  end

  def show
    @recipe = Recipe.find(params[:id])
    #update the date format in the erb
  end

  def edit
    @recipe = Recipe.find(params[:id])
    @image = Image.new
    #update the date format in the erb
  end

  def add_recipe
    if !params[:recipe].empty?
      @recipe = Recipe.find(params[:recipe])
      current_recipes << @recipe.id
    end
    current_recipes = handle_unchecked_recipe_boxes(params[:recipe_ids]) if params[:recipe_ids]
    redirect_to new_story_path
  end

  def update
    @recipe = Recipe.find(params[:id])
    @recipe.update(recipe_params)
    collection = @recipe.ingredient_ids
    @recipe.ingredient_ids = handle_dem_checked_boxes(params[:recipe][:ingredient_ids], collection)
    @image = Image.create(image_params)
    @recipe.image_url = @image.image.url
    @recipe.save
    redirect_to @recipe
  end

  def destroy
    @recipe = Recipe.find(params[:id])
    @recipe.destroy
    redirect_to recipes_path
  end


  def favorite
    @recipe = Recipe.find(params[:id])
    type = params[:type]
    if type == "favorite"
      current_user.fav_recipes << @recipe
      redirect_back fallback_location: @recipe
    elsif type == "unfavorite"
      current_user.fav_recipes.delete(@recipe)
      redirect_back fallback_location: @recipe
    end
  end

private
  def recipe_params
    params.require(:recipe).permit(:name, :instruction, :difficulty, :image_url)
  end

  def image_params
    params[:recipe].require(:image).permit!
  end
end
