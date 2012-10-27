require 'spec_helper'

describe "posts/new" do
  before(:each) do
    assign(:post, stub_model(Post,
      :goal_id => 1,
      :title => "MyString",
      :description => "MyText",
      :link => "MyString",
      :pubDate => "",
      :guid => "MyString",
      :is_visible => false
    ).as_new_record)
  end

  it "renders new post form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => posts_path, :method => "post" do
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
