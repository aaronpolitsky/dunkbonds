require 'spec_helper'

describe "posts/edit" do
  before(:each) do
    @post = assign(:post, stub_model(Post,
      :goal_id => 1,
      :title => "MyString",
      :description => "MyText",
      :link => "MyString",
      :pubDate => "",
      :guid => "MyString",
      :is_visible => false
    ))
  end

  it "renders the edit post form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => posts_path(@post), :method => "post" do
      assert_select "input#post_goal_id", :name => "post[goal_id]"
      assert_select "input#post_title", :name => "post[title]"
      assert_select "textarea#post_description", :name => "post[description]"
      assert_select "input#post_link", :name => "post[link]"
      assert_select "input#post_pubDate", :name => "post[pubDate]"
      assert_select "input#post_guid", :name => "post[guid]"
      assert_select "input#post_is_visible", :name => "post[is_visible]"
    end
  end
end
