module Notion
  class Notion
    def onboard(member:, configuration:)
      @client = NotionClient.new(ENV['NOTION_API_TOKEN'], configuration['space_id'])
      unless @client.find_member(member.email)
        @client.create_member(member.email)
        return Result.new(:success, "OK: #{member.email} was succesfully invited to Notion.")
      end
      if @client.add_member(member.email)
        Result.new(:success, "OK: #{member.email} was succesfully added to Notion Workspace.")
      else
        Result.new(:error, "Error: can't add #{member.email} to Notion Workspace.")
      end
    end

    def offboard(member:, configuration:)
      @client = NotionClient.new(ENV['NOTION_API_TOKEN'], configuration['space_id'])
      if @client.remove_member(member.email)
        Result.new(:success, "OK: #{member.email} was succesfully removed from Notion Workspace.")
      else
        Result.new(:error, "Error: can't remove #{member.email} from Notion Workspace.")
      end
    end
  end
end
