# frozen_string_literal: true

class DynamicKeysTestController < ApplicationController
  # Wrapped under a `data` field – the issue's original example.
  def wrapped
    render json: {
      data: {
        can_do_thing: true,
        can_do_other_thing: false,
        can_do_third_thing: true,
      },
    }
  end

  # Root-level dynamic dict – the PE-1357 `check_memberships` shape.
  def root
    render json: {
      'org-one' => true,
      'org-two' => false,
      'org-three' => true,
    }
  end

  # Dynamic dict whose values follow a complex shape (intended for $ref override).
  def complex_values
    render json: {
      'tag-1' => { id: 1, label: 'urgent' },
      'tag-2' => { id: 2, label: 'normal' },
    }
  end

  # Request body has dynamic keys; response is plain.
  def create
    render json: { ok: true }, status: 201
  end

  # Closed object: a fixed shape that should disallow extras via additionalProperties: false.
  def closed
    render json: { id: 1, name: 'sample' }
  end
end
