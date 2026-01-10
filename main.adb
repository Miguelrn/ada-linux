with ADA.Text_IO; use ADA.Text_IO;
with Interfaces.C; use Interfaces.C;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Ada.Numerics; use Ada.Numerics;


procedure Main is 
   -- types
   subtype C_Bool is Interfaces.C.int;

   type Vec2 is record
      X, Y: float;
   end record;

   type Vec3 is record
      X, Y, Z: float;
   end record;

   procedure Init_Window(Width, Height: int; Title: in char_array)
      with Import => True, Convention => C,External_Name => "InitWindow";

   procedure Close_Window
      with Import => True, Convention => C, External_Name => "CloseWindow";

   function Window_Should_Close return C_Bool
      with Import => True, Convention => C, External_Name => "WindowShouldClose";

   procedure Begin_Drawing
      with Import => True, Convention => C, External_Name => "BeginDrawing";

   procedure End_Drawing
      with Import => True, Convention => C, External_Name => "EndDrawing";

   type Color is record
        r: unsigned_char;
        g: unsigned_char;
        b: unsigned_char;
        a: unsigned_char;
   end record
      with Convention => C_Pass_By_Copy;

   procedure Clear_Background(c: Color)
      with Import => True, Convention => C, External_Name => "ClearBackground";

   procedure Draw_Rectangle(posX, posY, Width, Height: int; c: Color)
      with Import => True, Convention => C, External_Name => "DrawRectangle";

   procedure Draw_Text(Text: char_array; PosX, PosY: int; FontSize: Int; C: Color)
      with Import => True, Convention => C, External_Name => "DrawText";

   procedure Draw_Line(Start_X, Start_Y, End_X, End_Y: int; Col: Color)
      with Import => True, Convention => C, External_Name => "DrawLine";

   procedure Draw_Line_Ex (Start_X, Start_Y, End_X, End_Y, Thickness: float; col: Color) 
      with Import => True, Convention => C, External_Name => "DrawLineEx";


   -- constants
   Screen_Width: constant int := 800;
   Screen_Height: constant int := 600;

   FPS: constant float := 60.0;
   dz: float := 1.0;
   angle: float := 0.0;

   Background: constant Color := (R => 16, G => 16, B => 16, A => 255);
   Foreground: constant Color := (R => 80, G => 255, B => 80, A => 255);

   vertices: constant array(1..8) of vec3 := (
      (x => 0.25, y => 0.25, z => 0.25),
      (x => -0.25, y => 0.25, z => 0.25),
      (x => -0.25, y => -0.25, z => 0.25),
      (x => 0.25, y => -0.25, z => 0.25),

      (x => 0.25, y => 0.25, z => -0.25),
      (x => -0.25, y => 0.25, z => -0.25),
      (x => -0.25, y => -0.25, z => -0.25),
      (x => 0.25, y => -0.25, z => -0.25)
   );

   type Index is new Positive;
   type Index_Array is array (positive range<>) of Index;

   faces: constant array(1..2) of Index_Array := (
      (1,2,3,4),
      (5,6,7,8)
   );


   -- helper functions
   function Project (P: Vec3) return Vec2 is
   begin
      return (P.X / P.Z, P.Y / P.Z);
   end Project;

   function Screen (P: Vec2) return Vec2 is
   begin
      -- -1..1 => 0..2 => 0..1 => 0..w
      -- transform object coordinates into screen coordinates
      return (
         X => (P.X + 1.0) / 2.0 * Float (Screen_Width),
         Y => (1.0 - (P.Y + 1.0) / 2.0) * Float (Screen_Height)
      );
   end Screen;

   function Translate_Z (P: Vec3; DZ: float) return Vec3 is
   begin
      return (X => P.X, Y => P.Y, Z => P.Z + DZ);
   end Translate_Z;

   function Rotate_XZ (P: Vec3; Angle: float) return Vec3 is
      C : constant float := Cos (Angle);
      S : constant float := Sin (Angle);
   begin
      return (
         X => P.X * C - P.Z * S,
         Y => P.Y,
         Z => P.X * S + P.Z * C
      );
   end Rotate_XZ;

   procedure Clear is
   begin
      Clear_Background (Background);
   end Clear;

   procedure Draw_Point (P : Vec2) is
      S: constant float := 10.0;
   begin
      Draw_Rectangle (
         int(P.X - S / 2.0),
         int(P.Y - S / 2.0),
         int(S),
         int(S),
         Foreground
      );
   end Draw_Point;

   procedure Draw_Line (A, B : Vec2) is
   begin
      Draw_Line_Ex (
         float(A.X), 
         float(A.Y),
         float(B.X), 
         float(B.Y),
         float(3.0),
         Foreground
      );
   end Draw_Line;

   procedure Frame is
      dt: constant float := 1.0/FPS;
   begin
      angle := angle + Pi * dt;
      --dz := dz + dt;

      clear;

      for vertice of vertices loop
         Draw_Point(Screen(Project(Translate_Z(Rotate_XZ(vertice, angle), dz))));
      end loop;

      for face of faces loop
         for index in face'Range loop
            declarevertice
               -- we shall not use mod as the ada array are not zero based and can be anything !!
               A: vec3 := vertices(index);
               Next_Index: Positive := (if index = face'Last then face'First else index + 1);
               B: vec3 := vertices(Next_Index);
            begin
               Draw_Line (
                  Screen(Project(Translate_Z(Rotate_XZ(A, angle), dz))), 
                  Screen(Project(Translate_Z(Rotate_XZ(B, angle), dz)))
               );
            end;
         end loop;
      end loop;

   end Frame;


begin
   Init_Window(Screen_Width, Screen_Height, To_C("Hypercube")); -- Null termination handled by To_C

   while Window_Should_Close = 0 loop
      Begin_Drawing;
      Clear;
      Frame;
      End_Drawing;   
      Delay(Duration(1.0/FPS));
   end loop;

      -- Draw_Text (To_C ("Hello from Ada"), 190, 200, 20, Foreground);
   
end;