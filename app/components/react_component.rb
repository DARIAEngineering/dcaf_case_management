# frozen_string_literal: true

# Used for rendering React components in our Rails views
class ReactComponent < ViewComponent::Base
  attr_reader :component, :raw_props

  def initialize(component, raw_props: {})
    super
    @component = component
    @raw_props = raw_props
  end

  def call
    helpers.tag.div(
      '',
      data: {
        react_component: component,
        props: props
      }
    )
  end

  private

  def props
    raw_props
  end
end
