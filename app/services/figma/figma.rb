module Figma
  class Figma
    def onboard(member:, configuration:)
      @client = FigmaClient.new(ENV['FIGMA_USER'], ENV['FIGMA_PASSWORD'])

      if @client.invite_member(member.email, configuration['team'])
        Result.new(:success, "OK: #{member.email} was succesfully invited to the Figma team.")
      else
        Result.new(:warning, "Warning: #{member.email} was already invited to the Figma team.")
      end
    end

    def offboard(member:, configuration:)
      @client = FigmaClient.new(ENV['FIGMA_USER'], ENV['FIGMA_PASSWORD'])

      if @client.remove_member(member.email, configuration['team'])
        Result.new(:success, "OK: #{member.email} was succesfully removed from the Figma team.")
      else
        Result.new(:warning, "Warning: #{member.email} was already removed from the Figma team.")
      end
    end
  end
end
