--MR4 Revised
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate	
	local e0=Effect.CreateEffect(c)	
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EVENT_PREDRAW)
	e0:SetRange(0x5f)
	e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e0:SetOperation(cid.preset)
	c:RegisterEffect(e0)
end
function cid.preset(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsLocation(LOCATION_HAND) then
		Duel.SendtoDeck(e:GetHandler(),nil,1,REASON_RULE)
		Duel.Draw(tp,1,REASON_RULE)
	end
	local g=Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_DECK+LOCATION_HAND,0,e:GetHandler())
	if g<40 then
		Debug.Message("There are less than 40 cards in a player's Deck")
		local WIN_REASON_GUARDIAN_GOD_EXODIA=0x1f
		Duel.Win(1-tp,WIN_REASON_GUARDIAN_GOD_EXODIA)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_EXTRA_TOMAIN_KOISHI)
	e1:SetTargetRange(0xff,0xff)
	e1:SetTarget(cid.val)
	Duel.RegisterEffect(e1,0)
	Duel.Exile(e:GetHandler(),REASON_RULE)
end
function cid.val(e,c)
	return c:IsLocation(LOCATION_EXTRA) and ((c:IsFacedown() and bit.band(c:GetType(),TYPE_LINK)<=0) or (c:IsFaceup() and not c:IsType(TYPE_PENDULUM) and not c:IsType(TYPE_PANDEMONIUM)))
end