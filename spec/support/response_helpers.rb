module ResponseHelpers
  def status_code(code)
    Rack::Utils.status_code(code)
  end
end
