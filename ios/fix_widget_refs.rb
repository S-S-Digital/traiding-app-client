require 'xcodeproj'

project = Xcodeproj::Project.open('Runner.xcodeproj')

# Walk entire tree, delete any PBXFileReference that points to a
# non-existent path on disk. With PBXFileSystemSynchronizedRootGroup
# (Xcode 16) nothing needs to be re-added manually — the target picks
# up files from the synced folder automatically. The leftover file
# references are orphan template entries the target wizard couldn't
# place cleanly.

removed = []

collect_refs = lambda do |group|
  group.children.to_a.each do |child|
    if child.is_a?(Xcodeproj::Project::Object::PBXGroup)
      collect_refs.call(child)
    elsif child.is_a?(Xcodeproj::Project::Object::PBXFileReference)
      next if child.source_tree != '<group>' && child.source_tree != 'SOURCE_ROOT'
      full = child.real_path.to_s
      unless File.exist?(full)
        removed << { name: child.path, full: full }
        child.remove_from_project
      end
    end
  end
end

collect_refs.call(project.main_group)

if removed.empty?
  puts "✅ no broken file refs"
else
  puts "removed #{removed.size} broken file ref(s):"
  removed.each { |r| puts "  #{r[:name]} → #{r[:full]}" }
end

project.save
puts "saved"
