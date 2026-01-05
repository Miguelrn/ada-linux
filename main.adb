with ADA.Text_IO; use ADA.Text_IO;
with Interfaces.C; use Interfaces.C;

procedure Main is 
    procedure Init_Window(Width, Height : Int; Title : Char_Array) -- procedure return void
        with Import => True, Convention => C, External_Name => "InitWindow";
    function Window_Should_Close return int
        with Import => True, Convention => C, External_Name => "WindowShouldClose";
    procedure Begin_Drawing
        with Import => True, Convention => C, External_Name => "BeginDrawing";
    procedure Clear_Background
        with Import => True, Convention => C, External_Name => "ClearBackground";
    procedure Draw_Text
        with Import => True, Convention => C, External_Name => "DrawText";
    procedure End_Drawing 
        with Import => True, Convention => C, External_Name => "EndDrawing";
begin
    Init_Window(800, 600, To_C("Hello from ADA")); -- Null termination handled by To_C
    while Window_Should_Close = 0 loop
        Begin_Drawing; 
        --Clear_Background(RAYWHITE);
        --Draw_Text("Hello, World!", 190, 200, 20, MAROON);
        End_Drawing;
    end loop;
end;