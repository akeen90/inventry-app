#!/usr/bin/env ruby

require 'xcodeproj'

project_path = 'Inventry.xcodeproj'

project = Xcodeproj::Project.open(project_path)

# Find and remove PhotoGalleryComponents.swift
project.files.each do |file|
  if file.name == 'PhotoGalleryComponents.swift'
    file.remove_from_project
    puts "Removed PhotoGalleryComponents.swift from project"
  end
end

project.save
puts "Project cleaned"
