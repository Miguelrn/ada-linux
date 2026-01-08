with ADA.Text_IO; use ADA.Text_IO;
with Interfaces.C; use Interfaces.C;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;


procedure Main is 
   -- types
   subtype C_Int   is Interfaces.C.int;
   subtype C_Float is Interfaces.C.C_float;
   subtype C_Char  is Interfaces.C.char;
   subtype C_UChar is Interfaces.C.unsigned_char;
   subtype C_Char_array is Interfaces.C.char_array;

   type Vec2 is record
      X, Y: Float;
   end record;

   type Vec3 is record
      X, Y, Z: Float;
   end record;
   
   type Color is record
      R: Interfaces.C.unsigned_char;
      G: Interfaces.C.unsigned_char;
      B: Interfaces.C.unsigned_char;
      A: Interfaces.C.unsigned_char;
   end record
   with Convention => C;
   for Color use record
      R at 0 range 0 .. 7;
      G at 1 range 0 .. 7;
      B at 2 range 0 .. 7;
      A at 3 range 0 .. 7;
   end record;
   for Color'Size use 32;

   procedure Init_Window(Width, Height: C_Int; Title: C_Char_array)
      with Import => True, Convention => C, External_Name => "InitWindow";

   function Window_Should_Close return C_Int
      with Import => True, Convention => C, External_Name => "WindowShouldClose";

   procedure Begin_Drawing
      with Import => True, Convention => C, External_Name => "BeginDrawing";

   procedure End_Drawing
      with Import => True, Convention => C, External_Name => "EndDrawing";

   procedure Clear_Background (C: Color)
      with Import => True, Convention => C, External_Name => "ClearBackground";

   procedure Draw_Text(Text: C_Char_array; PosX, PosY: C_Int; Font_Size : C_Int; Tint: Color)
      with Import => True, Convention => C, External_Name => "DrawText";

   procedure Draw_Line_Ex (Start_X, Start_Y, End_X, End_Y, Thickness : C_Float; C: Color) 
         with Import => True, Convention => C, External_Name => "DrawLineEx";

   procedure Draw_Rectangle(X, Y, Width, Height: C_Int; C: Color)
      with Import => True, Convention => C,External_Name => "DrawRectangle";



   -- constants
   Screen_Width: constant C_Int := 800;
   Screen_Height: constant C_Int := 600;

   FPS: constant Integer := 60;

   Background: constant Color := (R => 16, G => 16, B => 16, A => 255);
   Foreground: constant Color :=(R => 80, G => 255, B => 80, A => 255);


   -- helper functions  
   function Color_To_Int(C: Color) return C_Int is
   begin
      return C_Int(C.R) * 16#1000000# +  -- 256^3
            C_Int(C.G) * 16#10000#  +  -- 256^2
            C_Int(C.B) * 16#100#    +  -- 256^1
            C_Int(C.A);               -- 256^0
   end Color_To_Int;

   function Project (P: Vec3) return Vec2 is
   begin
      return (P.X / P.Z, P.Y / P.Z);
   end Project;

   function Screen (P: Vec2) return Vec2 is
   begin
      return (
         X => (P.X + 1.0) / 2.0 * Float (Screen_Width),
         Y => (1.0 - (P.Y + 1.0) / 2.0) * Float (Screen_Height)
      );
   end Screen;

   function Translate_Z (P: Vec3; DZ: Float) return Vec3 is
   begin
      return (X => P.X, Y => P.Y, Z => P.Z + DZ);
   end Translate_Z;

   function Rotate_XZ (P: Vec3; Angle: Float) return Vec3 is
      C : constant Float := Cos (Angle);
      S : constant Float := Sin (Angle);
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
      S : constant Float := 20.0;
   begin
      Draw_Rectangle (
         C_Int(P.X - S / 2.0),
         C_Int(P.Y - S / 2.0),
         C_Int(S),
         C_Int(S),
         Foreground
      );
   end Draw_Point;


   procedure Draw_Line (A, B : Vec2) is
   begin
      Draw_Line_Ex (
         C_Float(A.X), 
         C_Float(A.Y),
         C_Float(B.X), 
         C_Float(B.Y),
         C_Float(3.0),
         Foreground
      );
   end Draw_Line;


begin
   Init_Window(Screen_Width, Screen_Height, To_C("Hypercube")); -- Null termination handled by To_C
   while Window_Should_Close = 0 loop
      Begin_Drawing;
      Clear_Background(Background);
      Draw_Text(To_C("Hello from Ada"), 190, 200, 20, Foreground);
      End_Drawing;
   end loop;
end;