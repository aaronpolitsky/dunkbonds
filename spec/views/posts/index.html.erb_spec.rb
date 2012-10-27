require 'spec_helper'

describe "posts/index" do
  before(:each) do
    assign(:posts, [
      stub_model(Post,
        :goal_id => 1,
        :title => "Title",
        :description => "MyText",
        :link => "Link",
        :pubDate => "",
        :guid => "Guid",
        :is_visible => false
      ),
      stub_model(Post,
        :goal_id => 1,
        :title => "Title",
        :description => "MyText",
        :link => "Link",
        :pubDate => "",
        :guid => "Guid",
        :is_visible => false
      )
    ])
  end

  it "renders a list of posts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Link".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "Guid".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
