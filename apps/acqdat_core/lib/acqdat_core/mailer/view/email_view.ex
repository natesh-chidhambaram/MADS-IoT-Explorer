defmodule AcqdatCore.EmailView do
  use Phoenix.View,
    root: "lib/acqdat_core/mailer/templates",
    namespace: AcqdatCore

  # Use all HTML functionality (forms, tags, etc)
  use Phoenix.HTML
end
