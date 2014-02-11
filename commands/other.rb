class MyCommand

  def aff *args
    p 'in aff'
    p args

  end

  def cmd_gotoup
    p 'goto up'
    
  end

  ## Code to do the sorting of the tree contents when clicked on
  def sort_by(tree, col, direction)
    tree.children(nil).map!{|row| [tree.get(row, col), row.id]} .
      sort(&((direction)? proc{|x, y| y <=> x}: proc{|x, y| x <=> y})) .
      each_with_index{|info, idx| tree.move(info[1], nil, idx)}

    tree.heading_configure(col, :command=>proc{sort_by(tree, col, ! direction)})
  end
end