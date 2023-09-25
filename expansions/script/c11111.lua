--Tester
function c11111.initial_effect(c)
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e:SetRange(0xf7)
	e:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e:SetOperation(function() if Duel.Exile(c,REASON_RULE)==0 then Duel.SendtoDeck(c,nil,-2,REASON_RULE) end if c:IsPreviousLocation(LOCATION_HAND) then Duel.Draw(c:GetPreviousControler(),1,REASON_RULE) end end)
	c:RegisterEffect(e)
end
Duel.LoadScript("TrinityFormat.lua")
