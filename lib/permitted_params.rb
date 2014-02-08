class PermittedParams < Struct.new(:params, :controller)
  def method_missing(method, *args, &block)
    if method.match /_attributes\z/
      super
    else
      params_hash = args.length > 0 ? args[0] : params[method]
      permit(params_hash, method)
    end
  end

  def permit(params, as_type)
    attrs_method = "#{as_type}_attributes".to_sym
    permitted_params = send(attrs_method)
    begin
      params.try(:permit, *permitted_params)
    rescue => e
      Rails.logger.warn "Exception caught in PermittedParams"
      Rails.logger.warn "params: #{params.inspect}"
      Rails.logger.warn "permitted_params: #{permitted_params.inspect}"
      raise e
    end
  end

  def self.define(symbol, &block)
    define_method("#{symbol}_attributes") do
      attrs = Attributes.new(self)
      attrs.instance_eval(&block)
      attrs.attributes
    end
  end

  def self.setup(&block)
    block.call(Configurator.new)
  end

  class Configurator
    def method_missing(method, *args, &block)
      ::PermittedParams.define(method, &block)
    end
  end

  class Attributes
    attr_accessor :attributes

    def initialize(permitted_params)
      @attributes = []
      @permitted_params = permitted_params
    end

    def scalar(*attrs)
      self.attributes += attrs
    end

    def array(*attrs)
      attrs.each do |attr|
        self.attributes << {attr => []}
      end
    end

    def nested(*attrs_or_options)
      attrs = attrs_or_options
      if attrs_or_options.last.is_a? Hash
        options = attrs_or_options.pop
      else
        options = {}
      end

      attrs.each do |attr|
        # attr is like questions or questions_attributes
        attr = attr.to_s.gsub(/_attributes\z/, '')
        singular_attr = attr.singularize

        child_attrs = @permitted_params.send("#{singular_attr}_attributes")
        child_attrs << :id
        child_attrs << :_destroy if options[:allow_destroy]
        self.attributes << {"#{attr}_attributes".to_sym => child_attrs}
      end
    end

    def inherits(*other_attrs)
      other_attrs.each do |other_attr|
        self.attributes += @permitted_params.send("#{other_attr}_attributes")
      end
    end

    def action_is(action_name)
      @permitted_params.params[:action].to_sym == action_name.to_sym
    end

    def method_missing(method, *args, &block)
      controller = @permitted_params.controller
      if controller.respond_to? method
        controller.send(method, *args, &block)
      else
        super
      end
    end
  end
end

class ActionController::Base
protected
  def permitted_params
    PermittedParams.new(params, self)
  end
end
