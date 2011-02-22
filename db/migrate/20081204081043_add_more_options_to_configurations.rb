class AddMoreOptionsToConfigurations < ActiveRecord::Migration
  def self.up
    # If the server is in contest mode and
    #   Configuration['contest.multisites'] is true
    #   the menu for site administrator is shown.

    Configuration.create(:key => 'contest.multisites',
                         :value_type => 'boolean',
                         :value => 'false')

    # If Configuration['system.online_registration'] is true,
    #   the registration menu would appear

    Configuration.create(:key => 'system.online_registration',
                         :value_type => 'boolean',
                         :value => 'false')

    # If Configuration['system.user_setting_enabled'] is true,
    #   users can change their settings

    Configuration.create(:key => 'system.user_setting_enabled',
                         :value_type => 'boolean',
                         :value => 'true')
  end

  def self.down
    Configuration.find_by_key('contest.multisites').destroy
    Configuration.find_by_key('system.online_registration').destroy
    Configuration.find_by_key('system.user_setting_enabled').destroy
  end
end
