#!/usr/bin/env ruby

# Add WorkingCamera.swift to Xcode project
require 'xcodeproj'
require 'pathname'

# Path to your .xcodeproj
project_path = '/Users/aaronkeen/Documents/My Apps/Inventry2/ios-app/Inventry.xcodeproj'
file_to_add = '/Users/aaronkeen/Documents/My Apps/Inventry2/ios-app/Inventry/Views/WorkingCamera.swift'

begin
  # Open the project
  project = Xcodeproj::Project.open(project_path)
  
  # Find the main target
  target = project.targets.first
  
  # Find the Views group
  views_group = project.main_group.recursive_children.find { |child| 
    child.isa == 'PBXGroup' && child.name == 'Views'
  }
  
  if views_group.nil?
    # If Views group doesn't exist, find the main group
    views_group = project.main_group['Inventry'] || project.main_group
  end
  
  # Check if file already exists in project
  existing_file = views_group.recursive_children.find { |child| 
    child.isa == 'PBXFileReference' && child.name == 'WorkingCamera.swift'
  }
  
  if existing_file
    puts "✅ WorkingCamera.swift already in project"
  else
    # Add file reference
    file_ref = views_group.new_file(file_to_add)
    
    # Add to target
    target.add_file_references([file_ref])
    
    # Save project
    project.save
    
    puts "✅ WorkingCamera.swift added to Xcode project!"
    puts "📱 Now just:"
    puts "   1. Clean Build (Shift+Cmd+K)"
    puts "   2. Run (Cmd+R)"
  end
  
rescue LoadError
  puts "❌ Need to install xcodeproj gem first:"
  puts "   Run: sudo gem install xcodeproj"
  puts "   Then run this script again"
rescue => e
  puts "❌ Error: #{e.message}"
  puts ""
  puts "📝 Manual steps:"
  puts "   1. In Xcode, right-click Views folder"
  puts "   2. Select 'Add Files to Inventry...'"
  puts "   3. Choose WorkingCamera.swift"
  puts "   4. Click Add"
end
