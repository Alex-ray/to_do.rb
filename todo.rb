require 'csv'

class CsvParser
  attr_reader :csv, :tasks
  def initialize(csv)
    @csv = csv
    @tasks = []
    load!
  end

  def load!
    CSV.foreach(csv, :headers => true, :header_converters => :symbol) do |task|
      tasks << task.to_hash
    end
    p tasks
  end

  def save!(updated_tasks)
    CSV.open(csv, 'wb') do |csv|
      updated_tasks.each do |task|
        csv.add_row([task[:id],task[:todo],task[:complete]])
      end
    end
  end
end

class Task
  attr_accessor :id, :todo, :complete
  def initialize(args)
    @id = args[:id].to_i
    @todo = args[:todo]
    @complete = args[:complete] 
  end
end

class ArgvParse
  attr_accessor :argv, :data
  def initialize(argv)
    @argv = argv
    @data = {}
  end

  def command
    data[:command] = argv.shift
  end

  def complete_item
    data[:complete_item] = argv.shift.to_i
  end

  def add_item
    data[:add_item] = argv.join(' ')
  end
end

class Output
  attr_reader :list
  def initialize(args)
    @tasks = args[:list]
  end

  def self.task_complete(index)
    tasks.each do |task|
      if task.id == index
        puts "#{task.todo} with an index of #{task.id} has been added to your TODO list!"
      end
    end
  end

  def self.task_added(todo)
    id = (tasks.length + 1)
    puts "#{todo} with an index of #{id} has been added to your TODO list!"
  end

  def all_tasks(tasks)
    tasks.each do |task|
      puts "#{task.id}. #{completed(task)} #{task.todo}"
    end
  end

  def completed(task)
    return "[X]" if task.complete == "true"
           "[ ]"
  end

  def intro
    puts "Welcome to the Totally Outdated Do Operator TODO"
  end

end

class Controller

  attr_reader :input, :list, :output
  def initialize(args)
    @output = args[:output]
    @list = args[:list]
    @input = args[:input]
    load!
  end

  def load!
    list.make_list!
  end

  def add_task
    list.add(input.data[:add_item])
    output.task_added(input.data[:add_item])
  end

  def complete_task
    list.complete(input.data[:complete_item])
    output.task_complete(input.data[:complete_item])
  end

  def list_tasks
    output.all_tasks(list.tasks)
  end
end

class List
  attr_accessor :tasks
  attr_reader :data
  def initialize(args)
    @data = args[:data]
    @tasks = []
  end

  def make_list!
    data.each { |task| tasks << Task.new(task) }
  end 

  def self.add(todo)
    args = {}
    args[:tasks] = todo
    args[:id] = (tasks.length + 1)
    tasks << args
  end

  def self.complete(index)
    tasks.each do |task|
      task[:complete] = "true" if task[:id] = index
    end
  end
end


class Game
  def initialize
  csv_data = CsvParser.new('todo3.csv')

  list = List.new({data: csv_data.tasks})

  input = ArgvParse.new(ARGV)
  output = Output.new({list: list})

  command = input.command.upcase
  p command
  return output.intro if command.nil?

  case command
  when 'ADD' then input.add_task
  when 'COMPLETE' then input.complete_task
  end

  session = Controller.new({input: input, list: list, output: output})

  case command
  when 'ADD' then session.add_task
  when 'COMPLETE' then session.complete_task
  when 'LIST' then session.list_tasks
  end

  # csv_data.save!(list.tasks)
  end
end

Game.new

#Ended on display all lists --- works! Add and Delete next


