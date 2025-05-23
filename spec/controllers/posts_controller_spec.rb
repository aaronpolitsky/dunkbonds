require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe PostsController do
  render_views

  before :each do
    @goal = Factory.create(:goal)
  end

  # This should return the minimal set of attributes required to create a valid
  # Post. As you add validations to Post, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # PostsController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all posts as @posts" do
      post = @goal.posts.create! valid_attributes
      get :index, {:goal_id => @goal.to_param, }, valid_session
      assigns(:posts).should eq([post])
    end
  end

  describe "GET show" do
    it "assigns the requested post as @post" do
      post = @goal.posts.create! valid_attributes
      get :show, {:goal_id => @goal.to_param, :id => post.to_param}, valid_session
      assigns(:post).should eq(post)
    end
  end

  describe "GET new" do
    it "assigns a new post as @post" do
      get :new, {:goal_id => @goal.to_param }, valid_session
      assigns(:post).should be_a_new(Post)
    end
  end

  describe "GET edit" do
    it "assigns the requested post as @post" do
      post = @goal.posts.create! valid_attributes
      get :edit, {:goal_id => @goal.to_param, :id => post.to_param}, valid_session
      assigns(:post).should eq(post)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Post" do
        expect {
          post :create, {:goal_id => @goal.to_param, :post => valid_attributes}, valid_session
        }.to change(Post, :count).by(1)
      end

      it "assigns a newly created post as @post" do
        post :create, {:goal_id => @goal.to_param, :post => valid_attributes}, valid_session
        assigns(:post).should be_a(Post)
        assigns(:post).should be_persisted
      end

      it "redirects to the created post" do
        post :create, {:goal_id => @goal.to_param, :post => valid_attributes}, valid_session
        response.should redirect_to([@goal, @goal.posts.last])
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved post as @post" do
        # Trigger the behavior that occurs when invalid params are submitted
        Post.any_instance.stub(:save).and_return(false)
        post :create, {:goal_id => @goal.to_param, :post => {}}, valid_session
        assigns(:post).should be_a_new(Post)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Post.any_instance.stub(:save).and_return(false)
        post :create, {:goal_id => @goal.to_param, :post => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested post" do
        post = @goal.posts.create! valid_attributes
        # Assuming there are no other posts in the database, this
        # specifies that the Post created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Post.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:goal_id => @goal.to_param, :id => post.to_param, :post => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested post as @post" do
        post = @goal.posts.create! valid_attributes
        put :update, {:goal_id => @goal.to_param, :id => post.to_param, :post => valid_attributes}, valid_session
        assigns(:post).should eq(post)
      end

      it "redirects to the post" do
        post = @goal.posts.create! valid_attributes
        put :update, {:goal_id => @goal.to_param, :id => post.to_param, :post => valid_attributes}, valid_session
        response.should redirect_to([@goal, post])
      end
    end

    describe "with invalid params" do
      it "assigns the post as @post" do
        post = @goal.posts.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Post.any_instance.stub(:save).and_return(false)
        put :update, {:goal_id => @goal.to_param, :id => post.to_param, :post => {}}, valid_session
        assigns(:post).should eq(post)
      end

      it "re-renders the 'edit' template" do
        post = @goal.posts.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Post.any_instance.stub(:save).and_return(false)
        put :update, {:goal_id => @goal.to_param, :id => post.to_param, :post => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested post" do
      post = @goal.posts.create! valid_attributes
      expect {
        delete :destroy, {:goal_id => @goal.to_param, :id => post.to_param}, valid_session
      }.to change(Post, :count).by(-1)
    end

    it "redirects to the posts list" do
      post = @goal.posts.create! valid_attributes
      delete :destroy, {:goal_id => @goal.to_param, :id => post.to_param}, valid_session
      response.should redirect_to(goal_posts_url)
    end
  end

end
