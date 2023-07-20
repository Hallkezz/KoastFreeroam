class 'LoadNews'

function LoadNews:__init()
	Events:Subscribe( "Lang", self, self.Lang )
	Events:Subscribe( "ModuleLoad", self, self.ModuleLoad )
	Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )

	Network:Subscribe( "LoadNews", self, self.LoadNews )
end

function LoadNews:Lang( args )
	Network:Send( "GetENGNews" )
end

function LoadNews:ModuleLoad( args )
	if LocalPlayer:GetValue( "Lang" ) and LocalPlayer:GetValue( "Lang" ) == "ENG" then
		self:Lang()
	else
		Network:Send( "GetRUSNews" )
	end
end

function LoadNews:LoadNews( args )
	Events:Fire( "NewsAddItem", { name = "Новости", text = args.ntext } )
end

function LoadNews:ModuleUnload()
    Events:Fire( "NewsRemoveItem" )
end

loadnews = LoadNews()