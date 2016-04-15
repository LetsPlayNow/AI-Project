simulator_folders = ['GameObjects', 'Helpers', 'Simulator', 'World']
module_folder = 'ai_project'
simulator_root = Rails.root.join('lib', 'Processing')

simulator_folders.each do |simulator_folder|
  $LOAD_PATH << simulator_root.join(simulator_folder, module_folder)
end
