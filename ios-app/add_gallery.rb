#!/usr/bin/env ruby

require 'xcodeproj'

project_path = 'Inventry.xcodeproj'
file_to_add = 'Inventry/Views/PhotoGalleryComponents.swift'

project = Xcodeproj::Project.open(project_path)
target = project.targets.first

views_group = project.main_group.recursive_children.find { |c| 
  c.isa == 'PBXGroup' && c.name == 'Views'
}

views_group ||= project.main_group['Inventry'] || project.main_group

# Check if file already exists
existing = views_group.recursive_children.find { |c| 
  c.isa == 'PBXFileReference' && c.name == 'PhotoGalleryComponents.swift'
}

if existing
  puts "File already in project"
else
  file_ref = views_group.new_file(file_to_add)
  target.add_file_references([file_ref])
  project.save
  puts "PhotoGalleryComponents.swift added to project"
end
