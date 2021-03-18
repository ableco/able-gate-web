module Invision
  class Invision
    def onboard(member:, configuration:)
      @client = InvisionClient.new(
        ENV['INVISION_API_SESSION_ID'],
        ENV['INVISION_API_SESSION_TOKEN']
      )
      project = configuration['project']
      if @client.find_member(member.email)
        Result.new(:warning, "Warning: #{member.email} already added to Invision.")
      elsif @client.add_member(member, project)
        Result.new(:success, "OK: #{member.email} was succesfully added to Invision.")
      else
        Result.new(:error, "Error: can't add #{member.email} to Invision.")
      end
    end

    def offboard(member:)
      @client = InvisionClient.new(
        ENV['INVISION_API_SESSION_ID'],
        ENV['INVISION_API_SESSION_TOKEN']
      )
      if @client.find_member(member.email)
        if @client.remove_member(member)
          Result.new(:success, "OK: #{member.email} was succesfully removed from Invision projects.")
        else
          Result.new(:error, "Error: can't remove #{member.email} from Invision.")
        end
      else
        Result.new(:warning, "Warning: #{member.email} doesnt't belong to the organization on Invision.")
      end
    end
  end
end
