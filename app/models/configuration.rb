require 'yaml'

#
# This class also contains various login of the system.
#
class Configuration < ActiveRecord::Base

  SYSTEM_MODE_CONF_KEY = 'system.mode'
  TEST_REQUEST_EARLY_TIMEOUT_KEY = 'contest.test_request.early_timeout'

  # set @@cache = true to only reload once.
  @@cache = false

  @@configurations = nil
  @@task_grading_info = nil

  def self.get(key)
    if @@cache
      if @@configurations == nil
        self.read_config
      end
      return @@configurations[key]
    else
      return Configuration.read_one_key(key)
    end
  end

  def self.[](key)
    self.get(key)
  end

  def self.reload
    self.read_config
  end

  def self.clear
    @@configurations = nil
  end

  def self.cache?
    @@cache
  end

  def self.enable_caching
    @@cache = true
  end

  #
  # View decision
  #
  def self.show_submitbox_to?(user)
    mode = get(SYSTEM_MODE_CONF_KEY)
    return false if mode=='analysis'
    if (mode=='contest') 
      return false if (user.site!=nil) and 
        ((user.site.started!=true) or (user.site.finished?))
    end
    return true
  end

  def self.show_tasks_to?(user)
    if time_limit_mode?
      return false if not user.contest_started?
    end
    return true
  end

  def self.show_grading_result
    return (get(SYSTEM_MODE_CONF_KEY)=='analysis')
  end

  def self.allow_test_request(user)
    mode = get(SYSTEM_MODE_CONF_KEY)
    early_timeout = get(TEST_REQUEST_EARLY_TIMEOUT_KEY)
    if (mode=='contest') 
      return false if ((user.site!=nil) and 
        ((user.site.started!=true) or 
         (early_timeout and (user.site.time_left < 30.minutes))))
    end
    return false if mode=='analysis'
    return true
  end

  def self.task_grading_info
    if @@task_grading_info==nil
      read_grading_info
    end
    return @@task_grading_info
  end
  
  def self.standard_mode?
    return get(SYSTEM_MODE_CONF_KEY) == 'standard'
  end

  def self.contest_mode?
    return get(SYSTEM_MODE_CONF_KEY) == 'contest'
  end

  def self.indv_contest_mode?
    return get(SYSTEM_MODE_CONF_KEY) == 'indv-contest'
  end

  def self.time_limit_mode?
    mode = get(SYSTEM_MODE_CONF_KEY)
    return ((mode == 'contest') or (mode == 'indv-contest')) 
  end
  
  def self.analysis_mode?
    return get(SYSTEM_MODE_CONF_KEY) == 'analysis'
  end
  
  def self.contest_time_limit
    contest_time_str = Configuration['contest.time_limit']

    if not defined? @@contest_time_str
      @@contest_time_str = nil
    end

    if @@contest_time_str != contest_time_str
      @@contest_time_str = contest_time_str
      if tmatch = /(\d+):(\d+)/.match(contest_time_str)
        h = tmatch[1].to_i
        m = tmatch[2].to_i
        
        @@contest_time = h.hour + m.minute
      else
        @@contest_time = nil
      end
    end  
    return @@contest_time
  end

  protected

  def self.convert_type(val,type)
    case type
    when 'string'
      return val
      
    when 'integer'
      return val.to_i
      
    when 'boolean'
      return (val=='true')
    end
  end    

  def self.read_config
    @@configurations = {}
    Configuration.find(:all).each do |conf|
      key = conf.key
      val = conf.value
      @@configurations[key] = Configuration.convert_type(val,conf.value_type)
    end
  end

  def self.read_one_key(key)
    conf = Configuration.find_by_key(key)
    if conf
      return Configuration.convert_type(conf.value,conf.value_type)
    else
      return nil
    end
  end

  def self.read_grading_info
    f = File.open(TASK_GRADING_INFO_FILENAME)
    @@task_grading_info = YAML.load(f)
    f.close
  end
  
end
