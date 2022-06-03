--Anemone Inquinante - Token per effetti
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
	local e1=c:FirstTimeProtection(false,true,true,true)
	e1:Desc(2,id-1)
	e1:SetProperty(e:GetProperty()|EFFECT_FLAG_CLIENT_HINT)
	local e2=c:UpdateATKDEFField(-1300,-1300,false,LOCATION_MZONE,LOCATION_MZONE,aux.TargetBoolFunction(aux.NOT(Card.IsCode),id-1))
	e2:Desc(3,id-1)
	e2:SetProperty(e:GetProperty()|EFFECT_FLAG_CLIENT_HINT)
	local e3=c:UpdateATKDEFField(1300,1300,false,LOCATION_MZONE,LOCATION_MZONE,aux.TargetBoolFunction(Card.IsCode,id-1))
	e3:Desc(4,id-1)
	e3:SetProperty(e:GetProperty()|EFFECT_FLAG_CLIENT_HINT)
end