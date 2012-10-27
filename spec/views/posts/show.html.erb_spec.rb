require 'spec_helper'

describe "posts/show" do
  before(:each) do
    @post = assign(:post, stub_model(Post,
      :goal_id => 1,
      :title => "Title",
      :description => "MyText",
      :link => "Link",
      :pubDate => "",
      :guid => "Guid",
      :is_visible => false
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Title/)
    rendered.should match(/MyText/)
    rendered.should match(/Link/)
    rendered.should match(//)
    rendered.should match(/Guid/)
    rendered.should match(/false/)
  end
end
