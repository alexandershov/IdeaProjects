functor
import
   System
define
   local X Y Z in
    thread
     % this thread will wait until X & Y are defined, it's kinda like declarative dataflow in Excel.
     Z = X + Y
     {System.showInfo Z}
    end
    {System.showInfo 'Hello Oz'}
    thread X = 3 end
    thread Y = 2 end
   end
end